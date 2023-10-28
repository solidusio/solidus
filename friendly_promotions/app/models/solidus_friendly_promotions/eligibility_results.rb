# frozen_string_literal: true

module SolidusFriendlyPromotions
  class EligibilityResults
    include Enumerable
    attr_reader :results, :promotion
    def initialize(promotion)
      @promotion = promotion
      @results = []
    end

    def add(item:, rule:, success:, code:, message:)
      results << EligibilityResult.new(
        item: item,
        rule: rule,
        success: success,
        code: code,
        message: message
      )
    end

    def success?
      return true if results.empty?
      promotion.actions.any? do |action|
        action.relevant_rules.all? do |rule|
          results_for_rule = results.select { |result| result.rule == rule }
          results_for_rule.any?(&:success)
        end
      end
    end

    def error_messages
      return [] if results.empty?
      results.group_by(&:rule).map do |rule, results|
        next if results.any?(&:success)
        results.detect { |r| !r.success }&.message
      end.compact
    end

    def each(&block)
      results.each(&block)
    end

    def last
      results.last
    end
  end
end
