FactoryGirl.define do
  factory :return_authorization, class: Spree::ReturnAuthorization do
    association(:order, factory: :shipped_order)
    stock_location { Spree::Fixtures.instance.stock_locations.default }
    association(:reason, factory: :return_authorization_reason)
    memo 'Items were broken'
  end

  factory :new_return_authorization, class: Spree::ReturnAuthorization do
    association(:order, factory: :shipped_order)
    stock_location { Spree::Fixtures.instance.stock_locations.default }
    association(:reason, factory: :return_authorization_reason)
  end

  factory :return_authorization_reason, class: Spree::ReturnAuthorizationReason do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
