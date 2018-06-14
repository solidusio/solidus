# frozen_string_literal: true

require 'spree/testing_support/factories/reimbursement_factory'
require 'spree/testing_support/factories/reimbursement_type_factory'

FactoryBot.define do
  factory :settlement, class: 'Spree::Settlement' do
    acceptance_status 'pending'
    reimbursement
    reimbursement_type
    transient do
      has_shipment? true
    end
    before(:create) do |settlement, evaluator|
      if evaluator.has_shipment?
        settlement.shipment ||= settlement.reimbursement.return_items.first.shipment
      end
    end
  end
end
