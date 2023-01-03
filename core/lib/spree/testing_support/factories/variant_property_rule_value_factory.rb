# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/variant_property_rule_factory'
  require 'spree/testing_support/factories/property_factory'
end

FactoryBot.define do
  factory :variant_property_rule_value, class: 'Spree::VariantPropertyRuleValue' do
    variant_property_rule
    property
  end
end

