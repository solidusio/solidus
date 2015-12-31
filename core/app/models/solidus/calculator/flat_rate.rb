require_dependency 'solidus/calculator'

module Solidus
  class Calculator::FlatRate < Calculator
    preference :amount, :decimal, default: 0
    preference :currency, :string, default: ->{ Solidus::Config[:currency] }

    def self.description
      Solidus.t(:flat_rate_per_order)
    end

    def compute(object=nil)
      if object && preferred_currency.upcase == object.currency.upcase
        preferred_amount
      else
        0
      end
    end
  end
end
