# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :role, class: 'Spree::Role' do
    sequence(:name) { |n| "Role ##{n}" }

    factory :admin_role do
      name { 'admin' }
    end
  end
end
