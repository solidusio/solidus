FactoryGirl.define do
  factory :order_promotion, class: Spree::OrderPromotion do
    association :order
    association :promotion
  end
end
