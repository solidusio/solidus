module Spree
  module PermittedAttributes
    module Admin
      ATTRIBUTES = [
        :line_item_attributes,
        :order_attributes,
        :shipment_attributes
      ]

      mattr_reader(*ATTRIBUTES)

      @@line_item_attributes = [:price, :variant_id, :sku] + PermittedAttributes.line_item_attributes

      @@order_attributes = [:import, :number, :completed_at, :locked_at, :channel, :user_id, :created_at]

      @@shipment_attributes = [:shipping_method, :stock_location, inventory_units: [:variant_id, :sku]] + PermittedAttributes.shipment_attributes
    end
  end
end
