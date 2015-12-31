FactoryGirl.define do
  factory :payment_method, aliases: [:credit_card_payment_method], class: Spree::Gateway::Bogus do
    name 'Credit Card'
  end

  factory :check_payment_method, class: Spree::PaymentMethod::Check do
    name 'Check'
  end

  # authorize.net was moved to spree_gateway.
  # Leaving this factory in place with bogus in case anyone is using it.
  factory :simple_credit_card_payment_method, class: Spree::Gateway::BogusSimple do
    name 'Credit Card'
  end

  factory :store_credit_payment_method, class: Spree::PaymentMethod::StoreCredit do
    name          "Store Credit"
    description   "Store Credit"
    active        true
    display_on    'none'
    auto_capture  true
  end
end
