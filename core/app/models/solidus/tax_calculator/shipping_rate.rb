# frozen_string_literal: true

module Solidus
  module TaxCalculator
    # Default implementation for tax calculations on shipping rates.
    #
    # The class used for shipping rate tax calculation is configurable, so that
    # the calculation can easily be pushed to third-party services. Users
    # looking to provide their own calculator should adhere to the API of this
    # class.
    #
    # @see Solidus::Tax::ShippingRateTaxer
    # @api experimental
    # @note This API is currently in development and likely to change.
    #   Specifically, the input format is not yet finalized.
    class ShippingRate
      include Solidus::Tax::TaxHelpers

      attr_reader :shipping_rate

      # Create a new tax calculator.
      #
      # @param [Solidus::Order] order the order to calculate taxes on
      # @return [Solidus::TaxCalculator::ShippingRate]
      def initialize(order)
        if order.is_a?(::Solidus::ShippingRate)
          Solidus::Deprecation.warn "passing a single shipping rate to Solidus::TaxCalculator::ShippingRate is DEPRECATED. It now expects an order"
          shipping_rate = order
          @order = shipping_rate.order
          @shipping_rate = shipping_rate
        else
          @order = order
          @shipping_rate = nil
        end
      end

      # Calculate taxes for a shipping rate.
      #
      # @param [Solidus::ShippingRate] shipping_rate the shipping rate to
      #   calculate taxes on
      # @return [Array<Solidus::Tax::ItemTax>] the calculated taxes for the
      #   shipping rate
      def calculate(shipping_rate)
        shipping_rate ||= @shipping_rate
        rates_for_item(shipping_rate).map do |rate|
          amount = rate.compute_amount(shipping_rate)

          Solidus::Tax::ItemTax.new(
            item_id: shipping_rate.id,
            label: rate.adjustment_label(amount),
            tax_rate: rate,
            amount: amount
          )
        end
      end
    end
  end
end
