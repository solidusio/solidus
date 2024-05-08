# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    module ConditionsHelper
      def options_for_condition_types(promotion_action, condition)
        options = promotion_action.available_conditions.map { |condition| [condition.model_name.human, condition.name] }
        options_for_select(options, condition&.type.to_s)
      end
    end
  end
end
