# frozen_string_literal: true

module SolidusFriendlyPromotions
  # Simple object to pass back discount data from a promoter.
  #
  # Will be used by {SolidusFriendlyPromotions::OrderDiscounter} to create or update promotion
  # adjustments on an order.
  #
  # @attr_reader [Integer] order_id the {Spree::Order} these discounts apply to
  # @attr_reader [Array<SolidusFriendlyPromotions::ItemDiscount>] line_item_discounts an array of
  #   discount data for order's line items
  # @attr_reader [Array<SolidusFriendlyPromotions::ItemDiscount>] shipment_discounts an array of
  #   discount data for the order's shipments
  class OrderDiscounts
    include ActiveModel::Model
    attr_accessor :order_id, :line_item_discounts, :shipment_discounts
  end
end
