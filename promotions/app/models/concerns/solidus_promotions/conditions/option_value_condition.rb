# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module OptionValueCondition
      def self.included(base)
        base.preference :eligible_values, :hash
        base.remove_method :preferred_eligible_values
      end

      def preferred_eligible_values
        values = preferences[:eligible_values] || {}
        values.keys.map(&:to_i).zip(
          values.values.map do |value|
            (value.is_a?(Array) ? value : value.split(",")).map(&:to_i)
          end
        ).to_h
      end
    end
  end
end
