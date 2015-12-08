FactoryGirl.define do
  sequence(:refund_transaction_id) { |n| "fake-refund-transaction-#{n}"}

  factory :refund, class: Spree::Refund do
    transient do
      payment_amount 100
    end

    amount 100.00
    transaction_id { generate(:refund_transaction_id) }
    payment do
      association(:payment, state: 'completed', amount: payment_amount)
    end
    association(:reason, factory: :refund_reason)
  end

  factory :refund_reason, class: Spree::RefundReason do
    sequence(:name) { |n| "Refund for return ##{n}" }
  end
end
