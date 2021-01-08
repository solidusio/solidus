# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :adjustment_reason, class: 'Spree::AdjustmentReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
    sequence(:code) { |n| "Code #{n}" }
  end
end
