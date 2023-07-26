# frozen_string_literal: true

module SolidusFriendlyPromotions
  class DiscountChooser
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def call(discounts)
      Array.wrap(
        discounts.min_by do |discount|
          [discount.amount, -discount.source&.id.to_i]
        end
      )
    end
  end
end
