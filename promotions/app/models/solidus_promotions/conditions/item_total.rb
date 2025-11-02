# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # A condition to apply to an order greater than (or greater than or equal to)
    # a specific amount
    #
    # To add extra operators please override `self.operators_map` or any other helper method.
    # To customize the error message you can also override `ineligible_message`.
    class ItemTotal < Condition
      include OrderLevelCondition

      preference :amount, :decimal, default: 100.00
      preference :currency, :string, default: -> { Spree::Config[:currency] }
      preference :operator, :string, default: "gt"

      # The list of allowed operators names mapped to their symbols.
      def self.operators_map
        {
          gte: :>=,
          gt: :>
        }
      end

      def self.operator_options
        operators_map.map do |name, _method|
          [I18n.t(name, scope: "solidus_promotions.item_total_condition.operators"), name]
        end
      end

      def order_eligible?(order, _options = {})
        return false unless order.currency == preferred_currency

        unless total_for_order(order).send(operator, threshold)
          eligibility_errors.add(:base, ineligible_message, error_code: ineligible_error_code)
        end

        eligibility_errors.empty?
      end

      private

      def operator
        self.class.operators_map.fetch(
          preferred_operator.to_sym,
          preferred_operator_default
        )
      end

      def total_for_order(order)
        order.item_total
      end

      def threshold
        BigDecimal(preferred_amount.to_s)
      end

      def formatted_amount
        Spree::Money.new(preferred_amount, currency: preferred_currency).to_s
      end

      def ineligible_message
        eligibility_error_message(ineligible_error_code, amount: formatted_amount)
      end

      def ineligible_error_code
        if preferred_operator == "gte"
          :item_total_less_than
        else
          :item_total_less_than_or_equal
        end
      end
    end
  end
end
