FactoryGirl.define do
  factory :variant_property_rule_value, class: Solidus::VariantPropertyRuleValue do
    variant_property_rule
    property
  end
end
