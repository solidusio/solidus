require 'spree/testing_support/sequences'
require 'spree/testing_support/factories/promotion_factory'

FactoryGirl.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    value { generate(:random_code) }
  end
end
