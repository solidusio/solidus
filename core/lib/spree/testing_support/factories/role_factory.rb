# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :role, class: 'Spree::Role' do
    sequence(:name) { |n| "Role ##{n}" }

    factory :admin_role do
      name { 'admin' }
    end
  end
end
