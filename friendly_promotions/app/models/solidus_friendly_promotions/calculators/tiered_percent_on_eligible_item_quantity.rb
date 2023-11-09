require_dependency "spree/calculator"

module SolidusFriendlyPromotions
  module Calculators
    class TieredPercentOnEligibleItemQuantity < SolidusFriendlyPromotions::Calculators::TieredPercent
      before_validation do
        # Convert tier values to decimals. Strings don't do us much good.
        if preferred_tiers.is_a?(Hash)
          self.preferred_tiers = preferred_tiers.map do |key, value|
            [cast_to_d(key.to_i), cast_to_d(value.to_s)]
          end.to_h
        end
      end

      def compute_line_item(line_item)
        order = line_item.order

        _base, percent = preferred_tiers.sort.reverse.detect do |value, _|
          eligible_line_items_quantity_total(order) >= value
        end
        if preferred_currency.casecmp(order.currency).zero?
          currency_exponent = ::Money::Currency.find(preferred_currency).exponent
          (line_item.discountable_amount * (percent || preferred_base_percent) / 100).round(currency_exponent)
        else
          0
        end
      end

      private

      def eligible_line_items_quantity_total(order)
        calculable.promotion.applicable_line_items(order).sum(&:quantity)
      end
    end
  end
end
