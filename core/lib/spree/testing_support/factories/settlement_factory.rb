# frozen_string_literal: true

require 'spree/testing_support/factories/reimbursement_factory'

FactoryBot.define do
  factory :settlement, class: 'Spree::Settlement' do
    acceptance_status 'pending'
    reimbursement
    transient do
      has_shipment? true
    end
    before(:create) do |settlement, _evaluator|
      if _evaluator.has_shipment?
        settlement.shipment ||= settlement.reimbursement.return_items.first.shipment
      end
    end
  end
end
