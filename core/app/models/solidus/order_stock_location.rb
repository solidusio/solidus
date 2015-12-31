module Spree
  class OrderStockLocation < Solidus::Base
    belongs_to :variant, class_name: "Solidus::Variant"
    belongs_to :stock_location, class_name: "Solidus::StockLocation"
    belongs_to :order, class_name: "Solidus::Order"

    def self.fulfill_for_order_with_stock_location(order, stock_location)
      self.where(order_id: order.id, stock_location_id: stock_location.id).each(&:fulfill_shipment!)
    end

    def fulfill_shipment!
      self.update_attributes!(shipment_fulfilled: true)
    end
  end
end