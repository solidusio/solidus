# frozen_string_literal: true

module Spree
  module Tax
    module TaxHelpers
      private

      def rates_for_item(item)
        @rates_for_item ||= Spree::TaxRate.item_level.for_address(item.order.tax_address)

        @rates_for_item.select do |rate|
          rate.active? && rate.tax_categories.map(&:id).include?(item.tax_category_id)
        end
      end
    end
  end
end
