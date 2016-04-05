require_dependency 'spree/calculator'

module Spree
  class Calculator::DefaultTax < Calculator
    include Spree::Tax::TaxHelpers

    def self.description
      Spree.t(:default_tax)
    end

    # Default tax calculator still needs to support orders for legacy reasons
    # Orders created before Spree 2.1 had tax adjustments applied to the order, as a whole.
    # Orders created with Spree 2.2 and after, have them applied to the line items individually.
    def compute_order(order)
      matched_line_items = order.line_items.select do |line_item|
        line_item.tax_category == rate.tax_category
      end

      line_items_total = matched_line_items.sum(&:discounted_amount)
      if rate.included_in_price
        order_tax_amount = round_to_two_places(line_items_total - ( line_items_total / (1 + rate.amount) ) )
        refund_if_necessary(order_tax_amount, order.tax_zone)
      else
        round_to_two_places(line_items_total * rate.amount)
      end
    end

    # When it comes to computing shipments or line items: same same.
    def compute_item(item)
      if rate.included_in_price
        deduced_total_by_rate(item, rate)
      else
        round_to_two_places(item.discounted_amount * rate.amount)
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
      BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
    end

    def deduced_total_by_rate(item, rate)
      unrounded_net_amount = item.discounted_amount / (1 + sum_of_included_tax_rates(item))
      refund_if_necessary(
        round_to_two_places(unrounded_net_amount * rate.amount),
        item.order.tax_zone
      )
    end

    def refund_if_necessary(amount, order_tax_zone)
      if default_zone_or_zone_match?(order_tax_zone)
        amount
      else
        amount * -1
      end
    end

    def default_zone_or_zone_match?(order_tax_zone)
      Zone.default_tax.try!(:contains?, order_tax_zone) || rate.zone.contains?(order_tax_zone)
    end
  end
end
