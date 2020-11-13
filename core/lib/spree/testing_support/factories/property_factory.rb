# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :property, class: 'Spree::Property' do
    name { 'baseball_cap_color' }
    presentation { 'cap color' }
  end
end
