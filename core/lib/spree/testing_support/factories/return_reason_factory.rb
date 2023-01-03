# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking
end

FactoryBot.define do
  factory :return_reason, class: 'Spree::ReturnReason' do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end

