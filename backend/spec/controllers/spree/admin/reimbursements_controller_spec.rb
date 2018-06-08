# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ReimbursementsController, type: :controller do
  stub_authorization!

  let!(:default_refund_reason) do
    Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false)
  end

  describe '#edit' do
    let(:reimbursement) { create(:reimbursement) }
    let(:order) { reimbursement.order }
    let!(:active_stock_location) { create(:stock_location, active: true) }
    let!(:inactive_stock_location) { create(:stock_location, active: false) }

    subject do
      get :edit, params: { order_id: order.to_param, id: reimbursement.to_param }
    end

    it "loads all the active stock locations" do
      subject
      expect(assigns(:stock_locations)).to include(active_stock_location)
      expect(assigns(:stock_locations)).not_to include(inactive_stock_location)
    end

    describe "#load_return_items" do
      let!(:second_shipment) { create(:shipment, order: order) }
      let!(:second_return_item) {
        create(
          :return_item,
          inventory_unit: second_shipment.inventory_units.first,
          reimbursement: reimbursement,
          acceptance_status: 'accepted'
        )
      }

      context "without existing settlements" do
        it "has 2 new @form_settlement" do
          subject
          expect(assigns(:form_settlements).size).to eq 2
          expect(assigns(:form_settlements).select(&:new_record?).size).to eq 2
        end
      end

      context "with existing settlement" do
        let!(:settlement) { create(:settlement, reimbursement: reimbursement, shipment: second_shipment) }

        it "has 1 existing settlement and 1 new settlement" do
          subject
          expect(assigns(:form_settlements).size).to eq 2
          expect(assigns(:form_settlements).select(&:persisted?)).to eq [settlement]
          expect(assigns(:form_settlements).select(&:new_record?).size).to eq 1
        end
      end
    end
  end

  describe '#create' do
    let(:customer_return) { create(:customer_return, line_items_count: 1) }
    let(:order) { customer_return.order }
    let(:return_item) { customer_return.return_items.first }
    let(:payment) { order.payments.first }
    before { return_item.receive! }

    subject do
      post :create, params: { order_id: order.to_param, build_from_customer_return_id: customer_return.id }
    end

    it 'creates the reimbursement' do
      expect { subject }.to change { order.reimbursements.count }.by(1)
      expect(assigns(:reimbursement).return_items.to_a).to eq customer_return.return_items.to_a
    end

    it 'redirects to the edit page' do
      subject
      expect(response).to redirect_to(spree.edit_admin_order_reimbursement_path(order, assigns(:reimbursement)))
    end

    context 'when create fails' do
      before do
        allow_any_instance_of(Spree::Reimbursement).to receive(:valid?) do |reimbursement, *_args|
          reimbursement.errors.add(:base, 'something bad happened')
          false
        end
      end

      context 'when a referer header is present' do
        let(:referer) { spree.edit_admin_order_customer_return_path(order, customer_return) }

        it 'redirects to the referer' do
          request.env["HTTP_REFERER"] = referer
          expect {
            post :create, params: { order_id: order.to_param }
          }.to_not change { Spree::Reimbursement.count }
          expect(response).to redirect_to(referer)
          expect(flash[:error]).to eq("something bad happened")
        end
      end

      context 'when a referer header is not present' do
        it 'redirects to the admin root' do
          expect {
            post :create, params: { order_id: order.to_param }
          }.to_not change { Spree::Reimbursement.count }
          expect(response).to redirect_to(spree.admin_path)
          expect(flash[:error]).to eq("something bad happened")
        end
      end
    end
  end

  describe "#perform" do
    let(:reimbursement) { create(:reimbursement) }
    let(:customer_return) { reimbursement.customer_return }
    let(:order) { reimbursement.order }
    let(:return_items) { reimbursement.return_items }
    let(:payment) { order.payments.first }

    subject do
      post :perform, params: { order_id: order.to_param, id: reimbursement.to_param }
    end

    it 'redirects to customer return page' do
      subject
      expect(response).to redirect_to spree.admin_order_reimbursement_path(order, reimbursement)
    end

    it 'performs the reimbursement' do
      expect {
        subject
      }.to change { payment.refunds.count }.by(1)
      expect(payment.refunds.last.amount).to be > 0
      expect(payment.refunds.last.amount).to eq return_items.to_a.sum(&:total)
    end

    context "a Spree::Core::GatewayError is raised" do
      before(:each) do
        def controller.perform
          raise Spree::Core::GatewayError.new('An error has occurred')
        end
      end

      it "sets an error message with the correct text" do
        subject
        expect(flash[:error]).to eq 'An error has occurred'
      end

      it 'redirects to the edit page' do
        subject
        redirect_path = spree.edit_admin_order_reimbursement_path(order, assigns(:reimbursement))
        expect(response).to redirect_to(redirect_path)
      end
    end
  end
end
