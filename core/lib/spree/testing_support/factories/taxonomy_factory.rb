# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :taxonomy, class: 'Spree::Taxonomy' do
    name { 'Brand' }
  end
end
