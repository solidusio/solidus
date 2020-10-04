# frozen_string_literal: true

module Spree
  module CalculatedAdjustments
    extend ActiveSupport::Concern

    included do
      has_one :calculator, class_name: "Spree::Calculator", as: :calculable, inverse_of: :calculable, dependent: :destroy, autosave: true
      accepts_nested_attributes_for :calculator, update_only: true
      validates :calculator, presence: true
    end

    class_methods do
      def calculators
        Spree::Deprecation.warn("Calling .calculators is deprecated. Please access through Rails.application.config.spree.calculators")

        spree_calculators.send model_name_without_spree_namespace
      end

      private

      def model_name_without_spree_namespace
        to_s.tableize.tr('/', '_').sub('spree_', '')
      end

      def spree_calculators
        Spree::Config.environment.calculators
      end
    end

    def calculator_type
      calculator.class.to_s if calculator
    end

    def calculator_type=(calculator_type)
      klass = calculator_type.constantize if calculator_type
      self.calculator = klass.new if klass && !calculator.instance_of?(klass)
    end
  end
end
