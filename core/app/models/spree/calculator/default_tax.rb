# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::DefaultTax < Calculator
    include Spree::Tax::TaxHelpers

    # Default tax calculator still needs to support orders for legacy reasons
    # Orders created before Spree 2.1 had tax adjustments applied to the order, as a whole.
    # Orders created with Spree 2.2 and after, have them applied to the line items individually.
    def compute_order(order)
      return 0 unless rate.active?
      matched_line_items = order.line_items.select do |line_item|
        rate.tax_categories.include?(line_item.tax_category)
      end

      line_items_total = matched_line_items.sum(&:total_before_tax)
      if rate.included_in_price
        round_to_two_places(line_items_total - ( line_items_total / (1 + rate.amount) ) )
      else
        round_to_two_places(line_items_total * rate.amount)
      end
    end

    # When it comes to computing shipments or line items: same same.
    def compute_item(item)
      return 0 unless rate.active?
      if rate.included_in_price
        deduced_total_by_rate(item, rate)
      else
        round_to_two_places(item.total_before_tax * rate.amount)
      end
    end

    alias_method :compute_shipment, :compute_item
    alias_method :compute_line_item, :compute_item
    alias_method :compute_shipping_rate, :compute_item

    private

    def rate
      calculable
    end

    def round_to_two_places(amount)
      BigDecimal(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
    end

    def deduced_total_by_rate(item, rate)
      round_to_two_places(
        rate.amount * item.total_before_tax / (1 + sum_of_included_tax_rates(item))
      )
    end

    def sum_of_included_tax_rates(item)
      rates_for_item(item).map(&:amount).sum
    end
  end
end
