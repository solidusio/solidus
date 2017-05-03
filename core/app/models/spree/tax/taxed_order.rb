module Spree
  module Tax
    # Simple object to pass back tax data from a calculator.
    #
    # Will be used by {Spree::OrderTaxation} to create or update tax
    # adjustments on an order.
    #
    # @attr_reader [Integer] id the {Spree::Order} these taxes apply to
    # @attr_reader [Array<Spree::Tax::TaxedItem>] line_item_taxes an array of
    #   tax data for order's line items
    # @attr_reader [Array<Spree::Tax::TaxedItem>] shipment_taxes an array of
    #   tax data for the order's shipments
    class TaxedOrder
      include ActiveModel::Model
      attr_accessor :id, :line_item_taxes, :shipment_taxes
    end
  end
end
