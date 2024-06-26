# frozen_string_literal: true

module SolidusFriendlyPromotions
  class EligibilityResults
    include Enumerable
    attr_reader :results, :promotion

    def initialize(promotion)
      @promotion = promotion
      @results = []
    end

    def add(item:, condition:, success:, code:, message:)
      results << EligibilityResult.new(
        item: item,
        condition: condition,
        success: success,
        code: code,
        message: message
      )
    end

    def success?
      return true if results.empty?
      promotion.benefits.any? do |benefit|
        benefit.conditions.all? do |condition|
          results_for_condition = results.select { |result| result.condition == condition }
          results_for_condition.any?(&:success)
        end
      end
    end

    def error_messages
      return [] if results.empty?
      results.group_by(&:condition).map do |_condition, results|
        next if results.any?(&:success)
        results.detect { |r| !r.success }&.message
      end.compact
    end

    def each(&block)
      results.each(&block)
    end

    delegate :last, to: :results
  end
end
