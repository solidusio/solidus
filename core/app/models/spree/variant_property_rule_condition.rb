module Spree
  class VariantPropertyRuleCondition < Spree::Base
    belongs_to :option_value
    belongs_to :variant_property_rule, touch: true

    validates_uniqueness_of :option_value_id, scope: :variant_property_rule_id
  end
end
