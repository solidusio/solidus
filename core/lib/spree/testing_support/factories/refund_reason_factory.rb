# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :refund_reason, class: 'Spree::RefundReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
  end
end
