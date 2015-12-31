FactoryGirl.define do
  factory :variant_property_rule_value, class: Spree::VariantPropertyRuleValue do
    variant_property_rule
    property
  end
end
