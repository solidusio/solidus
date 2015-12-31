FactoryGirl.define do
  factory :product_option_type, class: Solidus::ProductOptionType do
    product
    option_type
  end
end
