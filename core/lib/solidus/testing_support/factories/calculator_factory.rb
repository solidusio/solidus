# frozen_string_literal: true

FactoryBot.define do
  factory :calculator, aliases: [:flat_rate_calculator], class: 'Solidus::Calculator::FlatRate' do
    preferred_amount { 10.0 }
  end

  factory :no_amount_calculator, class: 'Solidus::Calculator::FlatRate' do
    preferred_amount { 0 }
  end

  factory :default_tax_calculator, class: 'Solidus::Calculator::DefaultTax' do
  end

  factory :shipping_calculator, class: 'Solidus::Calculator::Shipping::FlatRate' do
    preferred_amount { 10.0 }
  end

  factory :shipping_no_amount_calculator, class: 'Solidus::Calculator::Shipping::FlatRate' do
    preferred_amount { 0 }
  end

  factory :percent_on_item_calculator, class: 'Solidus::Calculator::PercentOnLineItem' do
    preferred_percent { 10 }
  end
end
