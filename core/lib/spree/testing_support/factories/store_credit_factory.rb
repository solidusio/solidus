FactoryGirl.define do
  factory :store_credit, class: Spree::StoreCredit do
    user             { create(:user) }
    created_by       { create(:user) }
    category         { create(:store_credit_category) }
    amount           { 150.00 }
    currency         { "USD" }
    credit_type      { create(:primary_credit_type) }
  end
end
