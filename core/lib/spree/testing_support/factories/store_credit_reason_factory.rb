# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :store_credit_reason, class: 'Spree::StoreCreditReason' do
    sequence :name do |n|
      "Input error #{n}"
    end
  end
end
