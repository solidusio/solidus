# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment_reason, class: 'Solidus::AdjustmentReason' do
    sequence(:name) { |n| "Refund for return ##{n}" }
    sequence(:code) { |n| "Code #{n}" }
  end
end
