FactoryGirl.define do
  factory :promotion_code, class: 'Solidus::PromotionCode' do
    promotion
    value { generate(:random_code) }
  end
end
