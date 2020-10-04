# frozen_string_literal: true

require 'factory_bot'

FactoryBot.define do
  sequence(:sku) { |n| "SKU-#{n}" }
  sequence(:email) { |n| "email#{n}@example.com" }
end
