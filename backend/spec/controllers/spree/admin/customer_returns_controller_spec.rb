# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Admin
    describe CustomerReturnsController, type: :controller do
      stub_authorization!

      describe "#index" do
        let(:order)           { customer_return.order }
        let(:customer_return) { create(:customer_return) }

        subject do
          get :index, params: { order_id: customer_return.order.to_param }
        end

        before { subject }

        it "loads the order" do
          expect(assigns(:order)).to eq order
        end

        it "loads the customer return" do
          expect(assigns(:customer_returns)).to include(customer_return)
        end
      end

      describe "#new" do
        let(:order) { create(:shipped_order, line_items_count: 1) }
        let!(:inactive_reimbursement_type)      { create(:reimbursement_type, active: false) }
        let!(:first_active_reimbursement_type)  { create(:reimbursement_type) }
        let!(:second_active_reimbursement_type) { create(:reimbursement_type) }

        subject do
          get :new, params: { order_id: order.to_param }
        end

        it "loads the order" do
          subject
          expect(assigns(:order)).to eq order
        end

        it "builds a new customer return" do
          subject
          expect(assigns(:customer_return)).to_not be_persisted
        end

        context "with previous customer return" do
          let(:return_reason_1) { create(:return_reason) }
          let(:return_reason_2) { create(:return_reason) }
          let(:return_reason_3) { create(:return_reason) }
          let!(:inactive_rma_reason) { create(:return_reason, active: false) }

          let(:order) { create(:shipped_order, line_items_count: 4) }
          let(:rma) { create(:return_authorization, order: order, reason: return_reason_1) }

          let!(:rma_return_item) { create(:return_item, return_authorization: rma, inventory_unit: order.inventory_units.first, return_reason: return_reason_2) }
          let!(:customer_return_return_item) { create(:return_item, return_authorization: nil, inventory_unit: order.inventory_units.last, return_reason: return_reason_3) }

          context "all return items are associated with a customer return" do
            let!(:previous_customer_return) { create(:customer_return_without_return_items, return_items: [rma_return_item, customer_return_return_item]) }

            before { subject }

            it "loads the possible return items" do
              total_inventory_count = 4
              rma_return_items_count = 1
              customer_return_return_items_count = 1
              expect(assigns(:new_return_items).length).to eq(total_inventory_count - rma_return_items_count - customer_return_return_items_count)
            end

            it "builds new return items" do
              expect(assigns(:new_return_items).all? { |return_item| !return_item.persisted? }).to eq true
            end

            it "does not have any rma return items" do
              expect(assigns(:rma_return_items)).to eq []
            end

            it "loads the correct return authorization reasons" do
              expect(assigns(:reasons)).to match_array([return_reason_1, return_reason_2, return_reason_3])
            end
          end

          context "there is a return item associated with an rma but not a customer return" do
            let!(:previous_customer_return) { create(:customer_return_without_return_items, return_items: [customer_return_return_item]) }

            before do
              subject
            end

            it "loads the possible return items" do
              rma_return_item_count = rma.return_items.count
              total_unit_count = order.inventory_units.count
              customer_returned_count = previous_customer_return.return_items.count
              expected_total = total_unit_count - customer_returned_count - rma_return_item_count
              expect(assigns(:new_return_items).length).to eq expected_total
            end

            it "builds new return items" do
              expect(assigns(:new_return_items).all? { |return_item| !return_item.persisted? }).to eq true
            end

            it "loads the persisted rma return items" do
              expect(assigns(:rma_return_items).all?(&:persisted?)).to eq true
            end

            it "has one rma return item" do
              expect(assigns(:rma_return_items)).to include(rma_return_item)
            end

            it "loads the correct return authorization reasons" do
              expect(assigns(:reasons)).to match_array([return_reason_1, return_reason_2, return_reason_3])
            end
          end
        end
      end

      describe "#edit" do
        let(:order)           { customer_return.order }
        let(:customer_return) { create(:customer_return, line_items_count: 3) }

        let!(:inactive_rma_reason) { create(:return_reason, active: false) }

        let!(:accepted_return_item)            { customer_return.return_items.order('id').first.tap(&:accept!) }
        let!(:rejected_return_item)            { customer_return.return_items.order('id').second.tap(&:reject!) }
        let!(:manual_intervention_return_item) { customer_return.return_items.order('id').third.tap(&:require_manual_intervention!) }

        subject do
          get :edit, params: { order_id: order.to_param, id: customer_return.to_param }
        end

        it "loads the order" do
          subject
          expect(assigns(:order)).to eq order
        end

        it "loads the customer return" do
          subject
          expect(assigns(:customer_return)).to eq customer_return
        end

        it "loads the accepted return items" do
          subject
          expect(assigns(:accepted_return_items)).to eq [accepted_return_item]
        end

        it "loads the rejected return items" do
          subject
          expect(assigns(:rejected_return_items)).to eq [rejected_return_item]
        end

        it "loads the return items that require manual intervention" do
          subject
          expect(assigns(:manual_intervention_return_items)).to eq [manual_intervention_return_item]
        end

        it "loads the return items that are still pending" do
          subject
          expect(assigns(:pending_return_items)).to eq []
        end

        it "loads the reimbursements that are still pending" do
          subject
          expect(assigns(:pending_reimbursements)).to eq []
        end

        it "loads the correct return authorization reasons" do
          subject
          expect(assigns(:reasons)).to match(Spree::ReturnReason.active)
        end

        context "a return item has an inactive return authorization reason" do
          before(:each) do
            accepted_return_item.update(return_reason_id: inactive_rma_reason.id)
          end

          it "includes the inactive return authorization reason" do
            subject
            expect(assigns(:reasons)).to match(Spree::ReturnReason.active + [inactive_rma_reason])
          end
        end
      end

      describe "#create" do
        let(:order) { create(:shipped_order, line_items_count: 1) }
        let(:reception_status_event) { 'receive' }
        let(:stock_location_id) { order.shipments.last.stock_location.id }
        let(:customer_return_params) do
          {
            order_id: order.to_param,
            customer_return: {
              stock_location_id: stock_location_id,
              return_items_attributes: {
                "0" => {
                  returned: "1",
                  amount: "15.99",
                  inventory_unit_id: order.inventory_units.shipped.last.id,
                  reception_status_event: reception_status_event
                }
              }
            }
          }
        end

        subject { post :create, params: customer_return_params }

        it { expect { subject }.to change { Spree::CustomerReturn.count }.by(1) }
        it do
          subject
          expect(response).to redirect_to spree.edit_admin_order_customer_return_path(order, id: Spree::CustomerReturn.last.id)
        end

        it 'executes the reception status event on the return items' do
          subject
          customer_return = Spree::CustomerReturn.last
          expect(customer_return.return_items.map(&:reception_status).uniq).to eq ['received']
        end

        context "missing stock location" do
          let(:stock_location_id) { '' }
          it { expect{ subject }.to_not change { Spree::CustomerReturn.count } }
          it { subject; expect(response).to render_template(:new) }
        end

        context "missing reception status event" do
          let(:reception_status_event) { '' }
          it { expect{ subject }.to_not change { Spree::CustomerReturn.count } }
          it { subject; expect(response).to redirect_to spree.new_admin_order_customer_return_path(order) }
        end
      end
    end
  end
end
