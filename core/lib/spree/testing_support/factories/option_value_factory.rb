# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :option_value, class: 'Spree::OptionValue' do
    sequence(:name) { |n| "Size-#{n}" }

    presentation { 'S' }
    option_type
  end
end
