FactoryGirl.define do
  factory :return_authorization, class: Spree::ReturnAuthorization do
    association(:order, factory: :shipped_order)
    association(:stock_location, factory: :stock_location)
    association(:reason, factory: :return_reason)
    memo 'Items were broken'
  end

  factory :new_return_authorization, class: Spree::ReturnAuthorization do
    association(:order, factory: :shipped_order)
    association(:stock_location, factory: :stock_location)
    association(:reason, factory: :return_reason)
  end

  factory :return_reason, class: Spree::ReturnReason do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
