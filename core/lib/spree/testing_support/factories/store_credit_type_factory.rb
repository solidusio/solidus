FactoryGirl.define do
  factory :primary_credit_type, class: Spree::StoreCreditType do
    name      Spree::StoreCreditType::DEFAULT_TYPE_NAME
    priority  { "1" }
  end

  factory :secondary_credit_type, class: Spree::StoreCreditType do
    name      { "Expiring" }
    priority  { "2" }
  end
end
