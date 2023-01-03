# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :store_credit_category, class: 'Spree::StoreCreditCategory' do
    name { "Exchange" }

    trait :reimbursement do
      name { Spree::StoreCreditCategory::REIMBURSEMENT }
    end

    trait :gift_card do
      name { Spree::StoreCreditCategory::GIFT_CARD }
    end
  end
end

