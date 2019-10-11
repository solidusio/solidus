# frozen_string_literal: true

module Solidus
  class VariantPropertyRuleCondition < Solidus::Base
    belongs_to :option_value, optional: true
    belongs_to :variant_property_rule, touch: true, optional: true

    validates_uniqueness_of :option_value_id, scope: :variant_property_rule_id
  end
end
