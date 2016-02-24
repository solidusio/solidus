require 'spec_helper'

describe Spree::ReimbursementTaxCalculator, type: :model do
  let(:order) { create(:shipped_order, line_items_count: 1, ship_address: address) }
  let(:customer_return) { create(:customer_return_with_accepted_items, shipped_order: order, line_items_count: 1) }
  let(:reimbursement) { create(:reimbursement, customer_return: customer_return, return_items_count: 1) }
  let(:return_item) { reimbursement.return_items.first }
  let(:line_item) { return_item.inventory_unit.line_item }
  let(:address) { create(:address) }

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
  end

  context 'with additional tax' do
    let!(:tax_rate) { create(:tax_rate, name: "Sales Tax", amount: 0.10, included_in_price: false, zone: tax_zone) }
    let(:tax_zone) { create(:zone, countries: [address.country]) }

    it 'sets additional_tax_total on the return items' do
      subject
      return_item.reload

      expect(return_item.additional_tax_total).to be > 0
      expect(return_item.additional_tax_total).to eq line_item.additional_tax_total
    end
  end

  context 'with included tax' do
    let!(:tax_rate) { create(:tax_rate, name: "VAT Tax", amount: 0.1, included_in_price: true, zone: tax_zone) }
    let(:tax_zone) { create(:zone, countries: [address.country]) }

    before do
      Spree::Config.default_tax_address = address
    end

    after do
      Spree::Config.default_tax_address = nil
    end

    it 'sets included_tax_total on the return items' do
      subject
      return_item.reload

      expect(return_item.included_tax_total).to be > 0
      expect(return_item.included_tax_total).to eq line_item.included_tax_total
    end
  end
end
