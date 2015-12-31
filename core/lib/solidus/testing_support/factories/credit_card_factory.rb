FactoryGirl.define do
  factory :credit_card, class: Solidus::CreditCard do
    verification_value 123
    month 12
    year { 1.year.from_now.year }
    number '4111111111111111'
    name 'Solidus Commerce'
    association(:payment_method, factory: :credit_card_payment_method)
    association(:address)
  end
end
