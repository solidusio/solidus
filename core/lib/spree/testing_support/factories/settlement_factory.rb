# frozen_string_literal: true

require 'spree/testing_support/factories/reimbursement_factory'
require 'spree/testing_support/factories/reimbursement_type_factory'

FactoryBot.define do
  factory :settlement, class: 'Spree::Settlement' do
    acceptance_status 'pending'
  end
end
