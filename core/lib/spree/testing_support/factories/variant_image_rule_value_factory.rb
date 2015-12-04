FactoryGirl.define do
  factory :variant_image_rule_value, class: Spree::VariantImageRuleValue do
    variant_image_rule
    image
  end
end
