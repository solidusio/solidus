FactoryGirl.define do
  factory :return_reason, class: Spree::ReturnReason do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
