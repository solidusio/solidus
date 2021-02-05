# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :variant_property_rule_condition, class: 'Spree::VariantPropertyRuleCondition' do
    variant_property_rule
    option_value
  end
end
