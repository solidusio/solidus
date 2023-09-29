# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Discountable
    class ShippingRate < SimpleDelegator
      attr_reader :discounts, :shipment

      def initialize(shipping_rate, shipment:)
        super(shipping_rate)
        @shipment = shipment
        @discounts = []
      end

      def shipping_rate
        __getobj__
      end

      def discountable_amount
        amount + discounts.sum(&:amount)
      end
    end
  end
end
