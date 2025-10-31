# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class TieredPercentOnEligibleItemQuantity < Spree::Calculator
      include PromotionCalculator

      preference :base_percent, :decimal, default: Spree::ZERO
      preference :tiers, :hash, default: { 10 => 5 }
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      before_validation :transform_preferred_tiers

      def compute_item(item)
        order = item.order

        _base, percent = preferred_tiers.sort.reverse.detect do |value, _|
          eligible_line_items_quantity_total(order) >= value
        end
        if preferred_currency.casecmp(order.currency).zero?
          round_to_currency(item.discountable_amount * (percent || preferred_base_percent) / 100, preferred_currency)
        else
          Spree::ZERO
        end
      end
      alias_method :compute_shipment, :compute_item
      alias_method :compute_shipping_rate, :compute_item
      alias_method :compute_line_item, :compute_item

      private

      def transform_preferred_tiers
        return unless preferred_tiers.is_a?(Hash)

        preferred_tiers.transform_keys!(&:to_i)
        preferred_tiers.transform_values! { |value| value.to_s.to_d }
      end

      def eligible_line_items_quantity_total(order)
        calculable.applicable_line_items(order).sum(&:quantity)
      end
    end
  end
end
