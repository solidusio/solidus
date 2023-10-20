# frozen_string_literal: true

module SolidusFriendlyPromotions
  class EligibilityResults
    attr_accessor :results_by_promotion
    def initialize
      @results_by_promotion = {}
    end

    def add(item:, rule:, success:, code:, message:)
      results_by_promotion[rule.promotion] ||= {}
      results_by_promotion[rule.promotion][rule] ||= []
      results_by_promotion[rule.promotion][rule] << EligibilityResult.new(
        item: item,
        success: success,
        code: code,
        message: message
      )
    end

    def for(promotion)
      results_by_promotion[promotion]
    end
  end
end
