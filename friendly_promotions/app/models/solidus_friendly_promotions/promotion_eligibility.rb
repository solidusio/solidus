# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionEligibility
    attr_reader :promotable, :promotion, :eligibility_results

    def initialize(promotable:, promotion:, eligibility_results: nil)
      @promotable = promotable
      @promotion = promotion
      @eligibility_results = eligibility_results
    end

    def call
      applicable_rules = promotion.rules.select do |rule|
        rule.applicable?(promotable)
      end

      applicable_rules.map do |applicable_rule|
        eligible = applicable_rule.eligible?(promotable)

        break [false] if !eligible && !eligibility_results

        if eligibility_results
          if applicable_rule.eligibility_errors.details[:base].first
            code = applicable_rule.eligibility_errors.details[:base].first[:error_code]
            message = applicable_rule.eligibility_errors.full_messages.first
          end
          eligibility_results.add(
            item: promotable,
            rule: applicable_rule,
            success: eligible,
            code: eligible ? nil : (code || :coupon_code_unknown_error),
            message: eligible ? nil : (message || I18n.t(:coupon_code_unknown_error, scope: [:solidus_friendly_promotions, :eligibility_errors]))
          )
        end

        eligible
      end.all?
    end
  end
end
