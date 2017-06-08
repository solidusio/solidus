require_dependency 'spree/calculator'

module Spree
  class Calculator::FlexiRate < Calculator
    preference :first_item,      :decimal, default: 0
    preference :additional_item, :decimal, default: 0
    preference :max_items,       :integer, default: 0
    preference :currency,        :string,  default: ->{ Spree::Config[:currency] }

    def self.available?(_object)
      true
    end

    def compute(object)
      if object && preferred_currency.casecmp(object.currency).zero?
        items_count = object.quantity
        items_count = [items_count, preferred_max_items].min unless preferred_max_items.zero?

        return BigDecimal.new(0) if items_count.zero?

        additional_items_count = items_count - 1
        preferred_first_item + preferred_additional_item * additional_items_count
      else
        BigDecimal.new(0)
      end
    end
  end
end
