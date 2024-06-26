# frozen_string_literal: true

module SolidusPromotions
  module Admin
    module ConditionsHelper
      def options_for_condition_types(benefit, condition)
        options = benefit.available_conditions.map { |condition| [condition.model_name.human, condition.name] }
        options_for_select(options, condition&.type.to_s)
      end
    end
  end
end
