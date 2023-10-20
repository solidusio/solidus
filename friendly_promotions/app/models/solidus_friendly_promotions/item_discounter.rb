# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ItemDiscounter
    attr_reader :promotions

    def initialize(promotions:)
      @promotions = promotions
    end

    def call(item)
      eligible_promotions = PromotionsEligibility.new(
        promotable: item,
        possible_promotions: promotions
      ).call

      eligible_promotions.flat_map do |promotion|
        promotion.actions.select do |action|
          action.can_discount?(item)
        end.map do |action|
          action.discount(item)
        end
      end
    end
  end
end
