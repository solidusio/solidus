# frozen_string_literal: true

require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/stock_location_factory'
require 'spree/testing_support/factories/return_reason_factory'

FactoryBot.define do
  factory :return_authorization, class: 'Spree::ReturnAuthorization' do
    association(:order, factory: :shipped_order)
    association(:stock_location, factory: :stock_location)
    association(:reason, factory: :return_reason)
    memo { 'Items were broken' }
  end

  factory :new_return_authorization, class: 'Spree::ReturnAuthorization' do
    association(:order, factory: :shipped_order)
    association(:stock_location, factory: :stock_location)
    association(:reason, factory: :return_reason)
  end
end
