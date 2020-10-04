# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  # A calculator for promotions that calculates a percent-off discount
  # for all matching products in an order. This should not be used as a
  # shipping calculator since it would be the same thing as a flat percent
  # off the entire order.
  #
  #
  # TODO Should be deprecated now that we have adjustments at the line item level in spree core

  class Calculator::PercentPerItem < Calculator
    preference :percent, :decimal, default: 0

    def compute(object = nil)
      return 0 if object.nil?
      object.line_items.sum { |line_item|
        value_for_line_item(line_item)
      }
    end

    private

    # Returns all products that match this calculator, but only if the calculator
    # is attached to a promotion. If attached to a ShippingMethod, nil is returned.
    # Copied from per_item.rb
    def matching_products
      if compute_on_promotion?
        calculable.promotion.rules.flat_map do |rule|
          rule.respond_to?(:products) ? rule.products : []
        end
      end
    end

    def value_for_line_item(line_item)
      if compute_on_promotion?
        return 0 unless matching_products.blank? || matching_products.include?(line_item.product)
      end
      ((line_item.price * line_item.quantity) * preferred_percent) / 100
    end

    # Determines wether or not the calculable object is a promotion
    def compute_on_promotion?
      @compute_on_promotion ||= calculable.respond_to?(:promotion)
    end
  end
end
