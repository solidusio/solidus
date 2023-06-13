# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ShipmentAdjuster
    attr_reader :promotions

    def initialize(promotions:)
      @promotions = promotions
    end

    def call(shipment)
      non_promotion_adjustments = shipment.adjustments.reject(&:promotion?)

      eligible_promotions = promotions.select do |promotion|
        PromotionEligibility.new(promotable: shipment, possible_promotions: promotions).call
      end

      possible_adjustments = eligible_promotions.flat_map do |promotion|
        promotion.actions.select do |action|
          action.can_adjust?(shipment)
        end.map do |action|
          action.adjust(shipment)
        end
      end

      chosen_adjustments = SolidusFriendlyPromotions.config.promotion_chooser_class.new(shipment).call(possible_adjustments)

      shipment.promo_total = chosen_adjustments.sum(&:amount)
      shipment.adjustments = non_promotion_adjustments + chosen_adjustments
      shipment
    end
  end
end
