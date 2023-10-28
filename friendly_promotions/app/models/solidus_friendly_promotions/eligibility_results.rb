# frozen_string_literal: true

module SolidusFriendlyPromotions
  class EligibilityResults
    attr_accessor :results_by_promotion
    def initialize
      @results_by_promotion = {}
    end

    def add(item:, rule:, success:, code:, message:)
      results_by_promotion[rule.promotion] ||= []
      results_by_promotion[rule.promotion] << EligibilityResult.new(
        item: item,
        rule: rule,
        success: success,
        code: code,
        message: message
      )
    end

    def for(promotion)
      results_by_promotion[promotion]
    end

    def success?(promotion)
      results_for_promotion = self.for(promotion)
      return true unless results_for_promotion
      promotion.actions.any? do |action|
        action.relevant_rules.all? do |rule|
          results_for_rule = results_for_promotion.select { |result| result.rule == rule }
          results_for_rule.any?(&:success)
        end
      end
    end

    def errors_for(promotion)
      results_for_promotion = self.for(promotion)
      return [] unless results_for_promotion
      results_for_promotion.group_by(&:rule).map do |rule, results|
        next if results.any?(&:success)
        results.detect { |r| !r.success }&.message
      end.compact
    end
  end
end
