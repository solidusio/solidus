# frozen_string_literal: true

require 'spree/testing_support/factories/customer_return_factory'
require 'spree/testing_support/factories/settlement_factory'

FactoryBot.define do
  factory :reimbursement, class: 'Spree::Reimbursement' do
    transient do
      return_items_count 1
      settlements_count 0
    end

    customer_return { create(:customer_return_with_accepted_items, line_items_count: return_items_count) }

    before(:create) do |reimbursement, _evaluator|
      reimbursement.order ||= reimbursement.customer_return.order
      if reimbursement.return_items.empty?
        reimbursement.return_items = reimbursement.customer_return.return_items
      end
      reimbursement.total = reimbursement.return_items.map { |ri| ri.amount }.sum
    end

    after(:create) do |reimbursement, evaluator|
      if evaluator.settlements_count > 0
        shipment = reimbursement.return_items.first.shipment
        create_list(:settlement, evaluator.settlements_count, reimbursement: reimbursement, shipment: shipment)
      end
    end
  end
end
