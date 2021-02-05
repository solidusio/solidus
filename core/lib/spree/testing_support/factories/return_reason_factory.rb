# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :return_reason, class: 'Spree::ReturnReason' do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
