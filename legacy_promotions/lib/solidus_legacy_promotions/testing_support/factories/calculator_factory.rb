# frozen_string_literal: true

FactoryBot.define do
  factory :flat_rate_calculator, class: 'Spree::Calculator::FlatRate' do
    preferred_amount { 10.0 }
  end

  factory :no_amount_calculator, class: 'Spree::Calculator::FlatRate' do
    preferred_amount { 0 }
  end

  factory :percent_on_item_calculator, class: 'Spree::Calculator::PercentOnLineItem' do
    preferred_percent { 10 }
  end
end
