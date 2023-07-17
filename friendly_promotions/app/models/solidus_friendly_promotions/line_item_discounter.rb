# frozen_string_literal: true

module SolidusFriendlyPromotions
  class LineItemDiscounter
    attr_reader :promotions

    def initialize(promotions:)
      @promotions = promotions
    end

    def call(line_item)
      return [] unless line_item.variant.product.promotionable?

      eligible_promotions = PromotionEligibility.new(
        promotable: line_item,
        possible_promotions: promotions
      ).call

      possible_adjustments = eligible_promotions.flat_map do |promotion|
        promotion.actions.select do |action|
          action.can_discount?(line_item)
        end.map do |action|
          action.discount(line_item)
        end
      end
    end
  end
end
