FactoryGirl.define do
  factory :price, class: Solidus::Price do
    variant
    amount 19.99
    currency 'USD'
  end
end
