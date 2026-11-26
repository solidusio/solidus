# frozen_string_literal: true

module SolidusPromotions
  # Simple object used to hold discount data for an item.
  #
  # This generic object will hold the amount of discount that should be applied to
  # an item.
  #
  # @attr [Spree::LineItem,Spree::Shipment] item the item to be discounted.
  # @attr [String] label information about the discount
  # @attr [ApplicationRecord] source will be used as the source for adjustments
  # @attr [BigDecimal] amount the amount of discount applied to the item
  class ItemDiscount
    include ActiveModel::Model

    attr_accessor :item, :label, :source, :amount

    def ==(other)
      item == other.item && label == other.label && source == other.source && amount == other.amount
    end
  end
end
