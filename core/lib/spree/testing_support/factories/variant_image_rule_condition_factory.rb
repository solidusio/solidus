FactoryGirl.define do
  factory :variant_image_rule_condition, class: Spree::VariantImageRuleCondition do
    variant_image_rule
    option_value
  end
end
