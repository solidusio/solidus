# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    module PromotionRulesHelper
      def options_for_promotion_rule_types(promotion_action, promotion_rule)
        options = promotion_action.available_conditions.map { |condition| [condition.model_name.human, condition.name] }
        options_for_select(options, promotion_rule&.type.to_s)
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
