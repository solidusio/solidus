# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

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
