# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::FlexiRate < Calculator
    preference :first_item,      :decimal, default: 0
    preference :additional_item, :decimal, default: 0
    preference :max_items,       :integer, default: 0
    preference :currency,        :string,  default: ->{ Spree::Config[:currency] }

    def self.available?(_object)
      Spree::Deprecation.warn('Spree::Calculator::FlexiRate::available is DEPRECATED. Use the instance method instead.')
      true
    end

    def compute(object)
      items_count = object.quantity
      items_count = [items_count, preferred_max_items].min unless preferred_max_items.zero?

      return BigDecimal(0) if items_count == 0

      additional_items_count = items_count - 1
      preferred_first_item + preferred_additional_item * additional_items_count
    end
  end
end
