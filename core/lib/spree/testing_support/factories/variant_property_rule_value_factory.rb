# frozen_string_literal: true

FactoryBot.define do
  factory :variant_property_rule_value, class: "Spree::VariantPropertyRuleValue" do
    variant_property_rule
    property
  end
end
