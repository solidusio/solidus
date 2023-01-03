# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  sequence(:sku) { |n| "SKU-#{n}" }
  sequence(:email) { |n| "email#{n}@example.com" }
end

