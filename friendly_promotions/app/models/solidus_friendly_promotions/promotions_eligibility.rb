# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionsEligibility
    attr_reader :promotable, :possible_promotions, :eligibility_results

    def initialize(promotable:, possible_promotions:, eligibility_results: nil)
      @promotable = promotable
      @possible_promotions = possible_promotions
      @eligibility_results = eligibility_results
    end

    def call
      possible_promotions.select do |candidate|
        PromotionEligibility.new(promotable: promotable, promotion: candidate, eligibility_results: eligibility_results).call
      end
    end
  end
end
