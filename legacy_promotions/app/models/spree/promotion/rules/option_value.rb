# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      class OptionValue < PromotionRule
        MATCH_POLICIES = %w(any)
        preference :match_policy, :string, default: MATCH_POLICIES.first
        preference :eligible_values, :hash

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(promotable, _options = {})
          case preferred_match_policy
          when 'any'
            promotable.line_items.any? { |item| actionable?(item) }
          end
        end

        def actionable?(line_item)
          pid = line_item.product.id
          ovids = line_item.variant.option_values.pluck(:id)

          product_ids.include?(pid) && (value_ids(pid) & ovids).present?
        end

        def preferred_eligible_values
          values = preferences[:eligible_values] || {}
          Hash[values.keys.map(&:to_i).zip(
            values.values.map do |value|
              (value.is_a?(Array) ? value : value.split(",")).map(&:to_i)
            end
          )]
        end

        private

        def product_ids
          preferred_eligible_values.keys
        end

        def value_ids(product_id)
          preferred_eligible_values[product_id]
        end
      end
    end
  end
end
