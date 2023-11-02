# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    module PromotionActionsHelper
      def options_for_promotion_action_calculator_types(promotion_action)
        calculators = promotion_action.available_calculators
        options = calculators.map { |calculator| [calculator.model_name.human, calculator.name] }
        options_for_select(options, promotion_action.calculator_type.to_s)
      end

      def options_for_promotion_action_types(promotion_action)
        actions = SolidusFriendlyPromotions.config.actions
        options = actions.map { |action| [action.model_name.human, action.name] }
        options_for_select(options, promotion_action&.type&.to_s)
      end

      def promotion_actions_by_level(promotion, level)
        promotion.actions.select { |action| action.level == level }
      end
    end
  end
end
