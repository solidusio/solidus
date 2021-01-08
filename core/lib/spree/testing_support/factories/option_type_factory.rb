# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :option_type, class: 'Spree::OptionType' do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation { 'Size' }
  end
end
