module Spree
  class VariantImageRuleCondition < Spree::Base
    belongs_to :option_value
    belongs_to :variant_image_rule, touch: true

    validates_uniqueness_of :option_value_id, scope: :variant_image_rule_id
  end
end
