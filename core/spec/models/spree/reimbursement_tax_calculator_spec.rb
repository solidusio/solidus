# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ReimbursementTaxCalculator, type: :model do
  let!(:tax_rate) { nil }

  let(:return_item) { reimbursement.return_items.first }
  let(:settlement) { reimbursement.settlements.first }
  let(:line_item) { return_item.inventory_unit.line_item }
  let(:order) { reimbursement.order }
  let(:shipment) { reimbursement.order.shipments.first }
  let(:reimbursement) { create(:reimbursement, return_items_count: 1, settlements_count: 1) }

  subject do
    Spree::ReimbursementTaxCalculator.call(reimbursement)
  end

  context 'without taxes' do
    let!(:tax_rate) { nil }

    it 'leaves the return items additional_tax_total and included_tax_total at zero' do
      subject

      expect(return_item.additional_tax_total).to eq 0
      expect(return_item.included_tax_total).to eq 0
    end

    it 'leaves the settlements additional_tax_total and included_tax_total at zero' do
      subject

      expect(settlement.additional_tax_total).to eq 0
      expect(settlement.included_tax_total).to eq 0
    end
  end

  context 'with additional tax' do
    let!(:tax_rate) { create(:tax_rate, name: "Sales Tax", amount: 0.10, included_in_price: false, zone: tax_zone) }
    let(:tax_zone) { create(:zone, :with_country) }
    let(:additional_tax_total) { shipment.cost * tax_rate.amount }

    before do
      shipment.additional_tax_total = additional_tax_total
      shipment.save

      subject
    end

    it 'sets additional_tax_total on the return items' do
      return_item.reload

      expect(return_item.additional_tax_total).to be > 0
      expect(return_item.additional_tax_total).to eq line_item.additional_tax_total
    end

    it 'sets additional_tax_total on the settlements' do
      settlement.reload

      expect(settlement.additional_tax_total).to be > 0
      expect(settlement.additional_tax_total).to eq shipment.additional_tax_total
    end
  end

  context 'with included tax' do
    let!(:tax_rate) { create(:tax_rate, name: "VAT Tax", amount: 0.1, included_in_price: true, zone: tax_zone) }
    let(:tax_zone) { create(:zone, :with_country) }
    let(:included_tax_total) { shipment.cost / (100 * (1 + tax_rate.amount)) }

    before do
      shipment.included_tax_total = included_tax_total
      shipment.save

      subject
    end

    it 'sets included_tax_total on the return items' do
      return_item.reload

      expect(return_item.included_tax_total).to be > 0
      expect(return_item.included_tax_total).to eq line_item.included_tax_total
    end

    it 'sets included_tax_total on the settlements' do
      settlement.reload

      expect(settlement.included_tax_total).to be > 0
      expect(settlement.included_tax_total).to eq shipment.included_tax_total
    end
  end
end
