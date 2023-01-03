# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :refund_reason, class: 'Spree::RefundReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
  end
end

