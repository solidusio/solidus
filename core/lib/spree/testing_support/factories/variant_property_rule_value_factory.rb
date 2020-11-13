# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :variant_property_rule_value, class: 'Spree::VariantPropertyRuleValue' do
    variant_property_rule
    property
  end
end
