FactoryGirl.define do
  factory :product_property, class: Solidus::ProductProperty do
    product
    property
  end
end
