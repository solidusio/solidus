# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    module PromotionRulesHelper
      def options_for_promotion_rule_types(promotion, level)
        existing = promotion.rules.map { |rule| rule.class.name }
        rules = SolidusFriendlyPromotions.config.send("#{level}_rules").reject { |rule| existing.include? rule.name }
        options = rules.map { |rule| [rule.model_name.human, rule.name] }
        options_for_select(options)
      end
    end
  end
end
