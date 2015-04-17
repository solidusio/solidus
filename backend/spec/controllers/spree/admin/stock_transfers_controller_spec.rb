require 'spec_helper'

module Spree
  describe Admin::StockTransfersController, :type => :controller do
    stub_authorization!

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
          transfer.closed_at = DateTime.now
        end }

      it "searches by stock location" do
        spree_get :index, :q => { :source_location_id_or_destination_location_id_eq => ny_store.id }
        assigns(:stock_transfers).count.should eq 1
        assigns(:stock_transfers).should include(stock_transfer1)
      end

      it "searches by status" do
        spree_get :index, :q => { :closed_at_null => 0 }
        assigns(:stock_transfers).count.should eq 1
        assigns(:stock_transfers).should include(stock_transfer2)
      end
    end

    context "#receive" do
      let!(:transfer_with_items) { create(:stock_transfer_with_items) }
      let(:variant_1) { transfer_with_items.transfer_items[0].variant }
      let(:variant_2) { transfer_with_items.transfer_items[1].variant }

      subject do
        spree_get :receive, parameters
      end

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
  end
end
