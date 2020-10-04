# frozen_string_literal: true

require 'spree/testing_support/factories/payment_factory'
require 'spree/testing_support/factories/refund_reason_factory'

FactoryBot.define do
  sequence(:refund_transaction_id) { |n| "fake-refund-transaction-#{n}" }

  factory :refund, class: 'Spree::Refund' do
    transient do
      payment_amount { 100 }
    end

    amount { 100.00 }
    transaction_id { generate(:refund_transaction_id) }
    perform_after_create { false }
    payment do
      association(:payment, state: 'completed', amount: payment_amount)
    end
    association(:reason, factory: :refund_reason)
  end
end
