# frozen_string_literal: true

module Solidus
  module TaxCalculator
    # Default implementation for tax calculations. Will go through all line
    # items and shipments and calculate their tax based on tax rates in the DB.
    #
    # The class used for tax calculation is configurable, so that the
    # calculation can easily be pushed to third-party services. Users looking
    # to provide their own calculator should adhere to the API of this class.
    #
    # @api experimental
    # @note This API is currently in development and likely to change.
    #   Specifically, the input format is not yet finalized.
    class Default
      include Solidus::Tax::TaxHelpers

      # Create a new tax calculator.
      #
      # @param [Solidus::Order] order the order to calculator taxes on
      # @return [Solidus::TaxCalculator::Default] a Solidus::TaxCalculator::Default object
      def initialize(order)
        @order = order
      end

      # Calculate taxes for an order.
      #
      # @return [Solidus::Tax::OrderTax] the calculated taxes for the order
      def calculate
        Solidus::Tax::OrderTax.new(
          order_id: order.id,
          line_item_taxes: line_item_rates,
          shipment_taxes: shipment_rates
        )
      end

      private

      attr_reader :order

      # Calculate the taxes for line items.
      #
      # @private
      # @return [Array<Solidus::Tax::ItemTax>] calculated taxes for the line items
      def line_item_rates
        order.line_items.flat_map do |line_item|
          calculate_rates(line_item)
        end
      end

      # Calculate the taxes for shipments.
      #
      # @private
      # @return [Array<Solidus::Tax::ItemTax>] calculated taxes for the shipments
      def shipment_rates
        order.shipments.flat_map do |shipment|
          calculate_rates(shipment)
        end
      end

      # Calculate the taxes for a single item.
      #
      # The item could be either a {Solidus::LineItem} or a {Solidus::Shipment}.
      #
      # Will go through all applicable rates for an item and create a new
      # {Solidus::Tax::ItemTax} containing the calculated taxes for the item.
      #
      # @private
      # @return [Array<Solidus::Tax::ItemTax>] calculated taxes for the item
      def calculate_rates(item)
        rates_for_item(item).map do |rate|
          amount = rate.compute_amount(item)

          Solidus::Tax::ItemTax.new(
            item_id: item.id,
            label: rate.adjustment_label(amount),
            tax_rate: rate,
            amount: amount,
            included_in_price: rate.included_in_price
          )
        end
      end
    end
  end
end
