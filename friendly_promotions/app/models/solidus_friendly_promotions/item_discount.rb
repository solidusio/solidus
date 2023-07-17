# frozen_string_literal: true

module SolidusFriendlyPromotions
  # Simple object used to hold discount data for an item.
  #
  # This generic object will hold the amount of discount that should be applied to
  # an item.
  #
  # @attr_reader [Spree::LineItem,Spree::Shipment] the item to be discounted.
  # @attr_reader [String] label information about the discount
  # @attr_reader [ApplicationRecord] source will be used as the source for adjustments
  # @attr_reader [BigDecimal] amount the amount of discount applied to the item
  class ItemDiscount
    include ActiveModel::Model
    attr_accessor :item, :label, :source, :amount

    def ==(other)
      item == other.item && label == other.label && source == other.source && amount == other.amount
    end
  end
end
