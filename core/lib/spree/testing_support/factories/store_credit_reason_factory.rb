# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit_reason, class: 'Spree::StoreCreditReason' do
    name { "Input error" }
  end
end
