# frozen_string_literal: true

module Spree
  module Tax
    # Simple object used to hold tax data for an item.
    #
    # This generic object will hold the amount of tax that should be applied to
    # an item. (Either a {Spree::LineItem} or a {Spree::Shipment}.)
    #
    # @attr_reader [Integer] item_id the {Spree::LineItem} or {Spree::Shipment} ID
    # @attr_reader [String] label information about the taxes
    # @attr_reader [Spree::TaxRate] tax_rate will be used as the source for tax
    #   adjustments
    # @attr_reader [BigDecimal] amount the amount of tax applied to the item
    # @attr_reader [Boolean] included_in_price whether the amount is included
    #   in the items price, or additional tax.
    class ItemTax
      include ActiveModel::Model
      attr_accessor :item_id, :label, :tax_rate, :amount, :included_in_price
    end
  end
end
