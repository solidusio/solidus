# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/payment_factory'
  require 'spree/testing_support/factories/refund_reason_factory'
end

FactoryBot.define do
  sequence(:refund_transaction_id) { |n| "fake-refund-transaction-#{n}" }

  factory :refund, class: 'Spree::Refund' do
    transient do
      payment_amount { 100 }
    end

    amount { 100.00 }
    transaction_id { generate(:refund_transaction_id) }
    payment do
      association(:payment, state: 'completed', amount: payment_amount)
    end
    association(:reason, factory: :refund_reason)
  end
end

