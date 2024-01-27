# frozen_string_literal: true

FactoryBot.define do
  factory :default_tax_calculator, class: 'Spree::Calculator::DefaultTax' do
  end

  factory :flat_fee_calculator, class: 'Spree::Calculator::FlatFee' do
  end

  factory :shipping_calculator, aliases: [:calculator], class: 'Spree::Calculator::Shipping::FlatRate' do
    preferred_amount { 10.0 }
  end

  factory :shipping_no_amount_calculator, class: 'Spree::Calculator::Shipping::FlatRate' do
    preferred_amount { 0 }
  end
end
