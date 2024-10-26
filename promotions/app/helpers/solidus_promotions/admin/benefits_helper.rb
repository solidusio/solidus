# frozen_string_literal: true

module SolidusPromotions
  module Admin
    module BenefitsHelper
      def options_for_benefit_calculator_types(benefit)
        calculators = benefit.available_calculators
        options = calculators.map { |calculator| [calculator.model_name.human, calculator.name] }
        options_for_select(options, benefit.calculator_type.to_s)
      end

      def options_for_benefit_types(benefit)
        benefits = SolidusPromotions.config.benefits
        options = benefits.map { |action| [action.model_name.human, action.name] }
        options_for_select(options, benefit&.type&.to_s)
      end
    end
  end
end
