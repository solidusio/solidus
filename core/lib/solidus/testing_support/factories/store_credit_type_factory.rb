# frozen_string_literal: true

FactoryBot.define do
  factory :primary_credit_type, class: 'Solidus::StoreCreditType' do
    name      { Solidus::StoreCreditType::DEFAULT_TYPE_NAME }
    priority  { "1" }
  end

  factory :secondary_credit_type, class: 'Solidus::StoreCreditType' do
    name      { Solidus::StoreCreditType::NON_EXPIRING }
    priority  { "2" }
  end
end
