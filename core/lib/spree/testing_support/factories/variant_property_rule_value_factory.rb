# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :variant_property_rule_value, class: 'Spree::VariantPropertyRuleValue' do
    variant_property_rule
    property
  end
end
