# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionsEligibility
    attr_reader :promotable, :possible_promotions, :collect_eligibility_results

    def initialize(promotable:, possible_promotions:, collect_eligibility_results: false)
      @promotable = promotable
      @possible_promotions = possible_promotions
      @collect_eligibility_results = collect_eligibility_results
    end

    def call
      possible_promotions.select do |candidate|
        PromotionEligibility.new(promotable: promotable, promotion: candidate, collect_eligibility_results: collect_eligibility_results).call
      end
    end
  end
end
