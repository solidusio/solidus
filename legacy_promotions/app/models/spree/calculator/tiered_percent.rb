# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::TieredPercent < Calculator
    preference :base_percent, :decimal, default: 0
    preference :tiers, :hash, default: {}
    preference :currency, :string, default: -> { Spree::Config[:currency] }

    before_validation do
      # Convert tier values to decimals. Strings don't do us much good.
      if preferred_tiers.is_a?(Hash)
        self.preferred_tiers = preferred_tiers.map do |key, value|
          [cast_to_d(key.to_s), cast_to_d(value.to_s)]
        end.to_h
      end
    end

    validates :preferred_base_percent, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    }
    validate :preferred_tiers_content

    def compute(object)
      order = object.is_a?(Order) ? object : object.order

      _base, percent = preferred_tiers.sort.reverse.detect do |value, _|
        order.item_total >= value
      end

      if preferred_currency.casecmp(order.currency).zero?
        currency_exponent = ::Money::Currency.find(preferred_currency).exponent
        (object.amount * (percent || preferred_base_percent) / 100).round(currency_exponent)
      else
        0
      end
    end

    private

    def cast_to_d(value)
      value.to_s.to_d
    rescue ArgumentError
      BigDecimal(0)
    end

    def preferred_tiers_content
      if preferred_tiers.is_a? Hash
        unless preferred_tiers.keys.all?{ |key| key.is_a?(Numeric) && key > 0 }
          errors.add(:base, :keys_should_be_positive_number)
        end
        unless preferred_tiers.values.all?{ |key| key.is_a?(Numeric) && key >= 0 && key <= 100 }
          errors.add(:base, :values_should_be_percent)
        end
      else
        errors.add(:preferred_tiers, :should_be_hash)
      end
    end
  end
end
