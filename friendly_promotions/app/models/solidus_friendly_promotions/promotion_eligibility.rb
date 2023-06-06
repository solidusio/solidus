# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionEligibility
    attr_reader :promotable, :possible_promotions

    def initialize(promotable:, possible_promotions:)
      @promotable = promotable
      @possible_promotions = possible_promotions
    end

    def call
      possible_promotions.select do |candidate|
        applicable_rules = candidate.rules.select do |rule|
          rule.applicable?(promotable)
        end

        applicable_rules.all? do |applicable_rule|
          applicable_rule.eligible?(promotable)
        end
      end
    end
  end
end
