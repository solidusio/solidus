FactoryGirl.define do
  factory :store_credit_event, class: Spree::StoreCreditEvent do
    store_credit       { create(:store_credit) }
    amount             { 100.00 }
    authorization_code { "#{store_credit.id}-SC-20140602164814476128" }

    factory :store_credit_auth_event, class: Spree::StoreCreditEvent do
      action             { Spree::StoreCredit::AUTHORIZE_ACTION }
    end

    factory :store_credit_capture_event do
      action             { Spree::StoreCredit::CAPTURE_ACTION }
    end
  end
end
