module Spree
  module PermittedAttributes
    module Admin
      ATTRIBUTES = [
        :line_item_option_attributes,
        :line_item_attributes,
        :order_attributes,
        :shipment_attributes
      ]

      mattr_reader(*ATTRIBUTES)

      @@line_item_option_attributes = [:price]

      @@line_item_attributes = [:sku]

      @@order_attributes = [:import, :number, :completed_at, :locked_at, :channel, :user_id, :created_at]

      @@shipment_attributes = [:shipping_method, :stock_location, inventory_units: [:variant_id, :sku]]

    end
  end
end
