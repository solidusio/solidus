# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :option_value, class: 'Spree::OptionValue' do
    sequence(:name) { |n| "Size-#{n}" }

    presentation { 'S' }
    option_type
  end
end

