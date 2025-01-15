# frozen_string_literal: true

module Spree
  module TaxCalculator
    # Default implementation for tax calculations. Will go through all line
    # items and shipments and calculate their tax based on tax rates in the DB.
    #
    # The class used for tax calculation is configurable, so that the
    # calculation can easily be pushed to third-party services. Users looking
    # to provide their own calculator should adhere to the API of this class.
    class Default
      include Spree::Tax::TaxHelpers

      # Create a new tax calculator.
      #
      # @param [Spree::Order] order the order to calculator taxes on
      # @return [Spree::TaxCalculator::Default] a Spree::TaxCalculator::Default object
      def initialize(order)
        @order = order
      end

      # Calculate taxes for an order.
      #
      # @return [Spree::Tax::OrderTax] the calculated taxes for the order
      def calculate
        Spree::Tax::OrderTax.new(
          order_id: order.id,
          order_taxes: order_rates,
          line_item_taxes: line_item_rates,
          shipment_taxes: shipment_rates
        )
      end

      private

      attr_reader :order

      # Calculate the order-level taxes.
      #
      # @private
      # @return [Array<Spree::Tax::ItemTax>] calculated taxes for the order
      def order_rates
        rates_for_order.map do |rate|
          amount = rate.compute_amount(order)

          Spree::Tax::ItemTax.new(
            label: rate.adjustment_label(amount),
            tax_rate: rate,
            amount:,
            included_in_price: rate.included_in_price
          )
        end
      end

      # Calculate the taxes for line items.
      #
      # @private
      # @return [Array<Spree::Tax::ItemTax>] calculated taxes for the line items
      def line_item_rates
        order.line_items.flat_map do |line_item|
          calculate_rates(line_item)
        end
      end

      # Calculate the taxes for shipments.
      #
      # @private
      # @return [Array<Spree::Tax::ItemTax>] calculated taxes for the shipments
      def shipment_rates
        order.shipments.flat_map do |shipment|
          calculate_rates(shipment)
        end
      end

      # Calculate the taxes for a single item.
      #
      # The item could be either a {Spree::LineItem} or a {Spree::Shipment}.
      #
      # Will go through all applicable rates for an item and create a new
      # {Spree::Tax::ItemTax} containing the calculated taxes for the item.
      #
      # @private
      # @return [Array<Spree::Tax::ItemTax>] calculated taxes for the item
      def calculate_rates(item)
        rates_for_item(item).map do |rate|
          amount = rate.compute_amount(item)

          Spree::Tax::ItemTax.new(
            item_id: item.id,
            label: rate.adjustment_label(amount),
            tax_rate: rate,
            amount:,
            included_in_price: rate.included_in_price
          )
        end
      end

      # @private
      # @return [Array<Spree::TaxRate>] rates that apply to an order
      def rates_for_order
        tax_category_ids = Set[
          *@order.line_items.map(&:variant_tax_category_id),
          *@order.shipments.map(&:tax_category_id)
        ]
        rates = Spree::TaxRate.active.order_level.for_address(@order.tax_address)
        rates.select do |rate|
          tax_category_ids.intersect?(rate.tax_category_ids.to_set)
        end
      end
    end
  end
end
