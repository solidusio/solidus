module Spree
  class OrderStockLocation < Spree::Base
    belongs_to :variant, class_name: "Spree::Variant"
    belongs_to :stock_location, class_name: "Spree::StockLocation"
    belongs_to :order, class_name: "Spree::Order"

    def self.fulfill_for_order_with_stock_location(order, stock_location)
      where(order_id: order.id, stock_location_id: stock_location.id).each(&:fulfill_shipment!)
    end

    def fulfill_shipment!
      update_attributes!(shipment_fulfilled: true)
    end
  end
end
