# frozen_string_literal: true

FactoryBot.define do
  factory :percent_on_item_calculator, class: 'Spree::Calculator::PercentOnLineItem' do
    preferred_percent { 10 }
  end
end
