# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Discountable
    class Shipment < SimpleDelegator
      attr_reader :discounts, :shipping_rates, :order

      def initialize(shipment, order:)
        super(shipment)
        @order = order
        @discounts = []
        @shipping_rates = shipment.shipping_rates.map { |shipping_rate| ShippingRate.new(shipping_rate, shipment: self) }
      end

      def shipment
        __getobj__
      end

      def discountable_amount
        amount + discounts.sum(&:amount)
      end
    end
  end
end
