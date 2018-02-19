# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::TieredFlatRate < Calculator
    preference :base_amount, :decimal, default: 0
    preference :tiers, :hash, default: {}
    preference :currency, :string, default: -> { Spree::Config[:currency] }

    before_validation do
      # Convert tier values to decimals. Strings don't do us much good.
      if preferred_tiers.is_a?(Hash)
        self.preferred_tiers = preferred_tiers.map do |k, v|
          [cast_to_d(k.to_s), cast_to_d(v.to_s)]
        end.to_h
      end
    end

    validate :preferred_tiers_content

    def compute(object)
      _base, amount = preferred_tiers.sort.reverse.detect do |b, _|
        object.amount >= b
      end

      if preferred_currency.casecmp(object.currency).zero?
        amount || preferred_base_amount
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
        unless preferred_tiers.keys.all?{ |k| k.is_a?(Numeric) && k > 0 }
          errors.add(:base, :keys_should_be_positive_number)
        end
      else
        errors.add(:preferred_tiers, :should_be_hash)
      end
    end
  end
end
