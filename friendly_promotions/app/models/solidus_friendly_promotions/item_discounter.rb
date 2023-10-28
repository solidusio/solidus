# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ItemDiscounter
    attr_reader :promotions, :collect_eligibility_results

    def initialize(promotions:, collect_eligibility_results: false)
      @promotions = promotions
      @collect_eligibility_results = collect_eligibility_results
    end

    def call(item)
      eligible_promotions = PromotionsEligibility.new(
        promotable: item,
        possible_promotions: promotions,
        collect_eligibility_results: collect_eligibility_results
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
