# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :store_credit, class: 'Spree::StoreCredit' do
    user
    association :created_by, factory: :user
    association :category, factory: :store_credit_category
    amount { 150.00 }
    currency { "USD" }
    association :credit_type, factory: :primary_credit_type
  end
end
