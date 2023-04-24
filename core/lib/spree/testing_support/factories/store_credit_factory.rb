# frozen_string_literal: true

FactoryBot.define do
  factory :store_credit, class: 'Spree::StoreCredit' do
    association :user, strategy: :create
    association :created_by, factory: :user, strategy: :create
    association :category, factory: :store_credit_category, strategy: :create
    amount { 150.00 }
    currency { "USD" }
    association :credit_type, factory: :primary_credit_type, strategy: :create
  end
end
