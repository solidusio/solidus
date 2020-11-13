# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :reimbursement_type, class: 'Spree::ReimbursementType' do
    sequence(:name) { |n| "Reimbursement Type #{n}" }
    active { true }
    mutable { true }
  end
end
