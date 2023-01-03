# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :payment_method, aliases: [:credit_card_payment_method], class: 'Spree::PaymentMethod::BogusCreditCard' do
    name { 'Credit Card' }
    available_to_admin { true }
    available_to_users { true }
  end

  factory :check_payment_method, class: 'Spree::PaymentMethod::Check' do
    name { 'Check' }
    available_to_admin { true }
    available_to_users { true }
  end

  # authorize.net was moved to spree_gateway.
  # Leaving this factory in place with bogus in case anyone is using it.
  factory :simple_credit_card_payment_method, class: 'Spree::PaymentMethod::SimpleBogusCreditCard' do
    name { 'Credit Card' }
    available_to_admin { true }
    available_to_users { true }
  end

  factory :store_credit_payment_method, class: 'Spree::PaymentMethod::StoreCredit' do
    name          { "Store Credit" }
    description   { "Store Credit" }
    active        { true }
    available_to_admin { false }
    available_to_users { false }
    auto_capture { true }
  end
end

