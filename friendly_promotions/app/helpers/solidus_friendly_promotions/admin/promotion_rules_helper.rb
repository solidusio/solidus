# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    module PromotionRulesHelper
      def options_for_promotion_rule_types(promotion_rule, level)
        existing = promotion_rule.promotion.rules.select(&:persisted?).map { |rule| rule.class.name }
        rules = SolidusFriendlyPromotions.config.send(:"#{level}_rules").reject { |rule| existing.include? rule.name }
        options = rules.map { |rule| [rule.model_name.human, rule.name] }
        options_for_select(options, promotion_rule.type.to_s)
      end

      def promotion_rules_by_level(promotion, level)
        promotion.rules.select do |rule|
          rule.level == level || rule_applicable_by_preference(rule, level)
        end
      end

      def rule_applicable_by_preference(rule, level)
        method_name = "preferred_#{level}_applicable"
        rule.respond_to?(method_name) && rule.send(method_name)
      end
    end
  end
end
