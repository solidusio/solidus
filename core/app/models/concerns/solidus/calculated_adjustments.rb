module Solidus
  module CalculatedAdjustments
    extend ActiveSupport::Concern

    included do
      has_one   :calculator, class_name: "Solidus::Calculator", as: :calculable, inverse_of: :calculable, dependent: :destroy, autosave: true
      accepts_nested_attributes_for :calculator
      validates :calculator, presence: true

      def self.calculators
        solidus_calculators.send model_name_without_solidus_namespace
      end

      def calculator_type
        calculator.class.to_s if calculator
      end

      def calculator_type=(calculator_type)
        klass = calculator_type.constantize if calculator_type
        self.calculator = klass.new if klass && !self.calculator.is_a?(klass)
      end

      private
      def self.model_name_without_solidus_namespace
        self.to_s.tableize.gsub('/', '_').sub('solidus_', '')
      end

      def self.solidus_calculators
        Rails.application.config.solidus.calculators
      end
    end
  end
end
