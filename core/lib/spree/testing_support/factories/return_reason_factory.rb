# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :return_reason, class: 'Spree::ReturnReason' do
    sequence(:name) { |n| "Defect ##{n}" }
  end
end
