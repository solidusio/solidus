# frozen_string_literal: true

FactoryBot.define do
  factory :return_reason, class: 'Solidus::ReturnReason' do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
