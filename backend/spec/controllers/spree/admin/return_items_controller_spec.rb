# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ReturnItemsController, type: :controller do
  stub_authorization!

  describe '#update' do
    let(:customer_return) { create(:customer_return) }
    let(:return_item) { customer_return.return_items.first }

    describe ':acceptance_status' do
      let(:old_acceptance_status) { 'pending' }
      let(:new_acceptance_status) { 'rejected' }

      subject do
        put :update, params: { id: return_item.to_param, return_item: { acceptance_status: new_acceptance_status } }
      end

      it 'updates the return item' do
        expect {
          subject
        }.to change { return_item.reload.acceptance_status }.from(old_acceptance_status).to(new_acceptance_status)
      end

      it 'redirects to the customer return' do
        subject
        expect(response).to redirect_to spree.edit_admin_order_customer_return_path(customer_return.order, customer_return)
      end
    end

    describe ':reception_status' do
      let(:old_reception_status) { 'in_transit' }
      let(:new_reception_status) { 'received' }
      let(:reception_status_event) { 'receive' }

      before do
        allow(Spree::Deprecation).to receive(:warn).with(a_string_matching('#process_inventory_unit! will not call'))

        return_item.update! reception_status: 'in_transit'
      end

      subject do
        put :update, params: { id: return_item.to_param, return_item: { reception_status_event: reception_status_event } }
      end

      it 'updates the return item' do
        expect {
          subject
        }.to change { return_item.reload.reception_status }.from(old_reception_status).to(new_reception_status)
        expect(customer_return.order.state).to eq('returned')
      end

      it 'redirects to the customer return' do
        subject
        expect(response).to redirect_to spree.edit_admin_order_customer_return_path(customer_return.order, customer_return)
      end
    end
  end
end
