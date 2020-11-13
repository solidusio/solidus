# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :variant_property_rule_condition, class: 'Spree::VariantPropertyRuleCondition' do
    variant_property_rule
    option_value
  end
end
