# frozen_string_literal: true

FactoryBot.define do
  factory :option_value, class: 'Solidus::OptionValue' do
    sequence(:name) { |n| "Size-#{n}" }

    presentation { 'S' }
    option_type
  end
end
