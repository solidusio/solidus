# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit_category, class: 'Solidus::StoreCreditCategory' do
    name { "Exchange" }
  end
end
