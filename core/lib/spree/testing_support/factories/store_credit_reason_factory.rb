# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit_reason, class: 'Spree::StoreCreditReason' do
    sequence :name do |n|
      "Input error #{n}"
    end
  end
end
