require 'spec_helper'

module Spree
  describe OrderStockLocation do
    describe ".fulfill_for_order_with_stock_location" do
      subject { OrderStockLocation.fulfill_for_order_with_stock_location(order, stock_location) }

      let(:order) { create(:order) }
      let(:stock_location) { create(:stock_location) }
      let!(:order_stock_location) { Spree::OrderStockLocation.create!(order: order, stock_location: stock_location) }

      it "fulfills the shipment for the order and stock location combination" do
        subject
        expect(order_stock_location.reload.shipment_fulfilled).to eq(true)
      end
    end
  end
end
