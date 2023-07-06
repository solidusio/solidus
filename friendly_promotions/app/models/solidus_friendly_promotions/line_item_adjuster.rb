# frozen_string_literal: true

module SolidusFriendlyPromotions
  class LineItemAdjuster
    attr_reader :promotions

    def initialize(promotions:)
      @promotions = promotions
    end

    def call(line_item)
      return unless line_item.variant.product.promotionable?
      non_promotion_adjustments = line_item.adjustments.reject(&:friendly_promotion?)

      eligible_promotions = PromotionEligibility.new(promotable: line_item, possible_promotions: promotions).call

      possible_adjustments = eligible_promotions.flat_map do |promotion|
        promotion.actions.select do |action|
          action.can_adjust?(line_item)
        end.map do |action|
          action.adjust(line_item)
        end
      end

      chosen_adjustments = SolidusFriendlyPromotions.config.promotion_chooser_class.new(line_item).call(possible_adjustments)

      line_item.promo_total = chosen_adjustments.sum(&:amount)
      line_item.adjustments = non_promotion_adjustments + chosen_adjustments
      line_item
    end
  end
end
