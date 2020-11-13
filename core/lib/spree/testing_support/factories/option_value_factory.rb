# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :option_value, class: 'Spree::OptionValue' do
    sequence(:name) { |n| "Size-#{n}" }

    presentation { 'S' }
    option_type
  end
end
