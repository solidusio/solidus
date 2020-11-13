# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :credit_card, class: 'Spree::CreditCard' do
    verification_value { 123 }
    month { 12 }
    year { 1.year.from_now.year }
    number { '4111111111111111' }
    name { 'Spree Commerce' }
    association(:payment_method, factory: :credit_card_payment_method)
    association(:address)

    trait :failing do
      number { "0000000000000000" }
    end
  end
end
