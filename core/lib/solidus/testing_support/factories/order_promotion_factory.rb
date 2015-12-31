FactoryGirl.define do
  factory :order_promotion, class: Solidus::OrderPromotion do
    association :order
    association :promotion
  end
end
