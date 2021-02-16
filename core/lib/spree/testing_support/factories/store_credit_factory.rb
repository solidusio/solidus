# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/store_credit_category_factory'
  require 'spree/testing_support/factories/store_credit_type_factory'
  require 'spree/testing_support/factories/user_factory'
end

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
