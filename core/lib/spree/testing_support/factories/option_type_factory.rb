# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :option_type, class: 'Spree::OptionType' do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation { 'Size' }
  end
end
