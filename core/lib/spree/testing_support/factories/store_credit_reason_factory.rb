# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :store_credit_reason, class: 'Spree::StoreCreditReason' do
    sequence :name do |n|
      "Input error #{n}"
    end
  end
end
