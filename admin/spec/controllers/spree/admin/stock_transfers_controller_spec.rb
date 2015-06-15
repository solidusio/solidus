require 'spec_helper'

module Spree
  describe Admin::StockTransfersController, :type => :controller do
    stub_authorization!

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


    context "#index" do
      it "searches by stock location" do
        spree_get :index, :q => { :source_location_id_or_destination_location_id_eq => ny_store.id }
        assigns[:stock_transfers].count.should eq 1
        assigns[:stock_transfers].should include(stock_transfer1)
      end

      it "searches by status" do
        spree_get :index, :q => { :closed_at_null => 0 }
        assigns[:stock_transfers].count.should eq 1
        assigns[:stock_transfers].should include(stock_transfer2)
      end
    end
  end
end
