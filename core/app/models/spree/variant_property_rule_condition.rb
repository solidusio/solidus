# frozen_string_literal: true

module Spree
  class VariantPropertyRuleCondition < Spree::Base
    belongs_to :option_value, optional: true
    belongs_to :variant_property_rule, touch: true, optional: true

    validates :option_value_id, uniqueness: { scope: :variant_property_rule_id }
  end
end
