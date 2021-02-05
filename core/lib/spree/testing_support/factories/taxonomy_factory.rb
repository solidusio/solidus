# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :taxonomy, class: 'Spree::Taxonomy' do
    name { 'Brand' }
  end
end
