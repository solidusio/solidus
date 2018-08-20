# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit_category, class: 'Spree::StoreCreditCategory' do
    name { "Exchange" }
  end
end
