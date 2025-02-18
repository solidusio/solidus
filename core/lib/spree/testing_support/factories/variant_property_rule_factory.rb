# frozen_string_literal: true

FactoryBot.define do
  factory :variant_property_rule, class: "Spree::VariantPropertyRule" do
    product

    transient do
      property { create(:property) }
      option_value { create(:option_value) }
      property_value { nil }
    end

    after(:build) do |rule, evaluator|
      rule.conditions.build(option_value: evaluator.option_value)
      rule.values.build(property: evaluator.property, value: evaluator.property_value)
    end
  end
end
