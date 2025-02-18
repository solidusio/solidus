# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit_category, class: "Spree::StoreCreditCategory" do
    name { "Exchange" }

    trait :reimbursement do
      name { Spree::StoreCreditCategory::REIMBURSEMENT }
    end

    trait :gift_card do
      name { Spree::StoreCreditCategory::GIFT_CARD }
    end
  end
end
