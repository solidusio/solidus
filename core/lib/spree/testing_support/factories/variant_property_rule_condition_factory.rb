# frozen_string_literal: true

FactoryBot.define do
  factory :variant_property_rule_condition, class: "Spree::VariantPropertyRuleCondition" do
    variant_property_rule
    option_value
  end
end
