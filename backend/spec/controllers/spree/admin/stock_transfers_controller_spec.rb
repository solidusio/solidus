require 'spec_helper'

module Spree
  describe Admin::StockTransfersController, :type => :controller do
    stub_authorization!

    shared_context 'ensures receivable stock transfer' do
      context 'outbound stock transfer' do
        before do
          transfer_with_items.update_attributes(finalized_at: nil, shipped_at: nil)
        end

        it 'redirects back to index' do
          subject
          expect(flash[:error]).to eq Spree.t(:stock_transfer_must_be_receivable)
          expect(response).to redirect_to(spree.admin_stock_transfers_path)
        end
      end
    end

    context "#index" do
      let(:warehouse) { StockLocation.create(name: "Warehouse")}
      let(:ny_store) { StockLocation.create(name: "NY Store")}
      let(:la_store) { StockLocation.create(name: "LA Store")}

      let!(:stock_transfer1) {
        StockTransfer.create do |transfer|
          transfer.source_location_id = warehouse.id
          transfer.destination_location_id = ny_store.id
        end }

      let!(:stock_transfer2) {
        StockTransfer.create do |transfer|
          transfer.source_location_id = warehouse.id
          transfer.destination_location_id = la_store.id
          transfer.finalized_at = DateTime.now
          transfer.closed_at = DateTime.now
        end }

      it "searches by stock location" do
        spree_get :index, :q => { :source_location_id_or_destination_location_id_eq => ny_store.id }
        assigns(:stock_transfers).count.should eq 1
        assigns(:stock_transfers).should include(stock_transfer1)
      end

      it "filters the closed stock transfers" do
        spree_get :index, :q => { :closed_at_null => '1' }
        expect(assigns(:stock_transfers)).to match_array [stock_transfer1]
      end

      it "doesn't filter any stock transfers" do
        spree_get :index, :q => { :closed_at_null => '0' }
        expect(assigns(:stock_transfers)).to match_array [stock_transfer1, stock_transfer2]
      end
    end

    context "#receive" do
      let!(:transfer_with_items) { create(:receivable_stock_transfer_with_items) }
      let(:variant_1)            { transfer_with_items.transfer_items[0].variant }
      let(:variant_2)            { transfer_with_items.transfer_items[1].variant }
      let(:parameters)           { { id: transfer_with_items.to_param } }

      subject do
        spree_get :receive, parameters
      end

      include_context 'ensures receivable stock transfer'

      context "no items have been received" do
        let(:parameters) do
          { id: transfer_with_items.to_param }
        end

        before { subject }

        it "doesn't assign received_items" do
          expect(assigns(:received_items)).to be_empty
        end
      end

      context "some items have been received" do
        let(:transfer_item) { transfer_with_items.transfer_items.first }
        let(:parameters) do
          { id: transfer_with_items.to_param, variant_search_term: variant_1.sku }
        end

        before do
          transfer_item.update_attributes(received_quantity: 1)
          subject
        end

        it "assigns received_items correctly" do
          expect(assigns(:received_items)).to match_array [transfer_item]
        end
      end
    end

    context "#close" do
      let!(:user) { create(:user) }
      let!(:transfer_with_items) { create(:receivable_stock_transfer_with_items) }

      before do
        allow(controller).to receive(:try_spree_current_user) { user }
      end

      subject do
        spree_put :close, id: transfer_with_items.to_param
      end

      include_context 'ensures receivable stock transfer'

      context "successfully closed" do
        it "redirects back to index" do
          subject
          expect(response).to redirect_to(spree.admin_stock_transfers_path)
        end

        it "sets the closed_by to the current user" do
          subject
          expect(transfer_with_items.reload.closed_by).to eq(user)
        end

        it "sets the closed_at date" do
          subject
          expect(transfer_with_items.reload.closed_at).to_not be_nil
        end

        context "stock movements" do
          let(:source)          { transfer_with_items.source_location }
          let(:destination)     { transfer_with_items.destination_location }
          let(:transfer_item_1) { transfer_with_items.transfer_items[0] }
          let(:transfer_item_2) { transfer_with_items.transfer_items[1] }

          before do
            transfer_item_1.update_columns(received_quantity: 2)
            transfer_item_2.update_columns(received_quantity: 5)
            subject
          end

          it 'creates 2 stock movements' do
            expect(assigns(:stock_movements).length).to eq 2
          end

          it 'sets the stock transfer as the originator of the stock movements' do
            subject
            originators = assigns(:stock_movements).map(&:originator)
            expect(originators).to match_array [transfer_with_items, transfer_with_items]
          end

          it 'only creates stock movements for the destination stock location' do
            subject
            locations = assigns(:stock_movements).map(&:stock_item).flat_map(&:stock_location)
            expect(locations).to match_array [destination, destination]
          end

          it 'creates the stock movements for the received quantities' do
            subject
            movement_for_transfer_item_1 = assigns(:stock_movements).find { |sm| sm.stock_item.variant == transfer_item_1.variant }
            expect(movement_for_transfer_item_1.quantity).to eq 2
            movement_for_transfer_item_2 = assigns(:stock_movements).find { |sm| sm.stock_item.variant == transfer_item_2.variant }
            expect(movement_for_transfer_item_2.quantity).to eq 5
          end
        end
      end

      context "error finalizing the stock transfer" do
        before do
          Spree::StockTransfer.any_instance.stub(update_attributes: false)
        end

        it "redirects back to receive" do
          subject
          expect(response).to redirect_to(spree.receive_admin_stock_transfer_path(transfer_with_items))
        end

        it "displays a flash error message" do
          subject
          expect(flash[:error]).to eq Spree.t(:unable_to_close_stock_transfer)
        end
      end
    end
  end
end
