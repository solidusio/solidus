# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :primary_credit_type, class: 'Spree::StoreCreditType' do
    name      { Spree::StoreCreditType::DEFAULT_TYPE_NAME }
    priority  { "1" }
  end

  factory :secondary_credit_type, class: 'Spree::StoreCreditType' do
    name      { Spree::StoreCreditType::NON_EXPIRING }
    priority  { "2" }
  end
end

