# frozen_string_literal: true

require_dependency "spree/calculator"
require_dependency "spree/shipping_calculator"

module Spree
  module Calculator::Shipping
    class FlexiRate < ShippingCalculator
      preference :first_item, :decimal, default: 0.0
      preference :additional_item, :decimal, default: 0.0
      preference :max_items, :integer, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def compute_package(package)
        compute_from_quantity(package.contents.sum(&:quantity))
      end

      def compute_from_quantity(quantity)
        sum = 0
        max = preferred_max_items.to_i
        quantity.times do |index|
          # check max value to avoid divide by 0 errors
          sum += if (max == 0 && index == 0) || (max > 0) && (index % max == 0)
            preferred_first_item.to_f
          else
            preferred_additional_item.to_f
          end
        end

        sum
      end
    end
  end
end
