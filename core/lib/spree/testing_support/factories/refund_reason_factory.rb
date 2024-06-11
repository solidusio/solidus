# frozen_string_literal: true

FactoryBot.define do
  factory :refund_reason, class: 'Spree::RefundReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
  end
end
