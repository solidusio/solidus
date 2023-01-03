# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/store_credit_factory'
  require 'spree/testing_support/factories/store_credit_reason_factory'
end

FactoryBot.define do
  factory :store_credit_event, class: 'Spree::StoreCreditEvent' do
    store_credit
    amount             { 100.00 }
    authorization_code { "#{store_credit.id}-SC-20140602164814476128" }
    action               { Spree::StoreCredit::AUTHORIZE_ACTION }

    factory :store_credit_auth_event, class: 'Spree::StoreCreditEvent' do
      action             { Spree::StoreCredit::AUTHORIZE_ACTION }
    end

    factory :store_credit_capture_event do
      action             { Spree::StoreCredit::CAPTURE_ACTION }
    end

    factory :store_credit_adjustment_event do
      action              { Spree::StoreCredit::ADJUSTMENT_ACTION }
      store_credit_reason { create(:store_credit_reason) }
    end

    factory :store_credit_invalidate_event do
      action              { Spree::StoreCredit::INVALIDATE_ACTION }
      store_credit_reason { create(:store_credit_reason) }
    end
  end
end

