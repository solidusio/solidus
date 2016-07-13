require 'spree/testing_support/factories/payment_method_factory'
require 'spree/testing_support/factories/credit_card_factory'
require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/store_credit_factory'

FactoryGirl.define do
  factory :payment, aliases: [:credit_card_payment], class: Spree::Payment do
    association(:payment_method, factory: :credit_card_payment_method)
    source { create(:credit_card, user: order.user) }
    order
    state 'checkout'
    response_code '12345'

    trait :failing do
      response_code '00000'
      association(:source, :failing, { factory: :credit_card })
    end

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
