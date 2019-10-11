# frozen_string_literal: true

FactoryBot.define do
  factory :option_type, class: 'Solidus::OptionType' do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation { 'Size' }
  end
end
