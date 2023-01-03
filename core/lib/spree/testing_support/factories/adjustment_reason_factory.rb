# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :adjustment_reason, class: 'Spree::AdjustmentReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
    sequence(:code) { |n| "Code #{n}" }
  end
end

