# frozen_string_literal: true

require 'solidus/testing_support/factories/option_value_factory'
require 'solidus/testing_support/factories/variant_property_rule_factory'

FactoryBot.define do
  factory :variant_property_rule_condition, class: 'Solidus::VariantPropertyRuleCondition' do
    variant_property_rule
    option_value
  end
end
