require 'spree/testing_support/factories/payment_method_factory'
require 'spree/testing_support/factories/credit_card_factory'

FactoryGirl.define do
  factory :payment, aliases: [:credit_card_payment], class: Spree::Payment do
    association(:payment_method, factory: :credit_card_payment_method)
    association(:source, factory: :credit_card)
    order
    state 'checkout'
    response_code '12345'

    factory :payment_with_refund do
      transient do
        refund_amount 5
      end

      amount { refund_amount }

      state 'completed'

      refunds { build_list :refund, 1, amount: refund_amount }
    end
  end

  factory :check_payment, class: Spree::Payment do
    association(:payment_method, factory: :check_payment_method)
    order
  end

  factory :store_credit_payment, class: Spree::Payment, parent: :payment do
    association(:payment_method, factory: :store_credit_payment_method)
    association(:source, factory: :store_credit)
  end
end
