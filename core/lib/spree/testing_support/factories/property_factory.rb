# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :property, class: 'Spree::Property' do
    name { 'baseball_cap_color' }
    presentation { 'cap color' }
  end
end
