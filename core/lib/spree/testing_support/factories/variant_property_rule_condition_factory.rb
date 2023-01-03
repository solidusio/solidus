# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/option_value_factory'
  require 'spree/testing_support/factories/variant_property_rule_factory'
end

FactoryBot.define do
  factory :variant_property_rule_condition, class: 'Spree::VariantPropertyRuleCondition' do
    variant_property_rule
    option_value
  end
end

