# frozen_string_literal: true

module Solidus
  class Promotion < Solidus::Base
    module Rules
      # A rule to apply to an order greater than (or greater than or equal to)
      # a specific amount
      class ItemTotal < PromotionRule
        preference :amount, :decimal, default: 100.00
        preference :currency, :string, default: ->{ Solidus::Config[:currency] }
        preference :operator, :string, default: '>'

        OPERATORS = ['gt', 'gte']

        def applicable?(promotable)
          promotable.is_a?(Solidus::Order)
        end

        def eligible?(order, _options = {})
          return false unless order.currency == preferred_currency
          item_total = order.item_total
          unless item_total.send(preferred_operator == 'gte' ? :>= : :>, BigDecimal(preferred_amount.to_s))
            eligibility_errors.add(:base, ineligible_message, error_code: ineligible_error_code)
          end

          eligibility_errors.empty?
        end

        private

        def formatted_amount
          Solidus::Money.new(preferred_amount, currency: preferred_currency).to_s
        end

        def ineligible_message
          if preferred_operator == 'gte'
            eligibility_error_message(:item_total_less_than, amount: formatted_amount)
          else
            eligibility_error_message(:item_total_less_than_or_equal, amount: formatted_amount)
          end
        end

        def ineligible_error_code
          if preferred_operator == 'gte'
            :item_total_less_than
          else
            :item_total_less_than_or_equal
          end
        end
      end
    end
  end
end
