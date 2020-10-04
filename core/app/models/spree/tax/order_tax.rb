# frozen_string_literal: true

module Spree
  module Tax
    # Simple object to pass back tax data from a calculator.
    #
    # Will be used by {Spree::OrderTaxation} to create or update tax
    # adjustments on an order.
    #
    # @attr_reader [Integer] order_id the {Spree::Order} these taxes apply to
    # @attr_reader [Array<Spree::Tax::ItemTax>] line_item_taxes an array of
    #   tax data for order's line items
    # @attr_reader [Array<Spree::Tax::ItemTax>] shipment_taxes an array of
    #   tax data for the order's shipments
    class OrderTax
      include ActiveModel::Model
      attr_accessor :order_id, :line_item_taxes, :shipment_taxes
    end
  end
end
