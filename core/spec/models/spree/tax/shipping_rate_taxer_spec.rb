# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Tax::ShippingRateTaxer do
  let(:shipping_rate) { build_stubbed(:shipping_rate) }

  subject(:taxer) { described_class.new(shipping_rate) }

  describe '#tax' do
    subject(:taxer) { described_class.new.tax(shipping_rate) }

    context 'with no matching tax rates' do
      it 'returns the object' do
        expect(subject).to eq(shipping_rate)
        expect(subject.taxes).to eq([])
      end
    end

    context 'with tax rates' do
      let(:ship_address) { create :address }
      let(:tax_category) { create :tax_category }
      let(:order) { create :order, ship_address: ship_address }
      let(:shipment) { create :shipment, order: order }
      let!(:shipping_method) { create :shipping_method, tax_category: tax_category, zones: [zone] }
      let(:zone) { create :zone, countries: [ship_address.country] }
      let!(:tax_rate_one) { create :tax_rate, tax_categories: [tax_category], zone: zone, amount: 0.1 }
      let!(:tax_rate_two) do
        create(
          :tax_rate,
          tax_categories: [create(:tax_category), tax_category],
          zone: zone,
          amount: 0.2
        )
      end
      let!(:non_applicable_rate) { create :tax_rate, zone: zone }
      let(:shipping_rate) { create :shipping_rate, cost: 10, shipping_method: shipping_method }

      it 'builds a shipping rate tax for every matching tax rate' do
        expect(subject.taxes.length).to eq(2)
        expect(subject.taxes.map(&:tax_rate)).to include(tax_rate_one)
        expect(subject.taxes.map(&:tax_rate)).to include(tax_rate_two)
        # This rate has a different tax category.
        expect(subject.taxes.map(&:tax_rate)).not_to include(non_applicable_rate)
      end

      it 'will produce a shipping rate that, when saved, also saves the taxes' do
        expect { subject.save }.to change(Spree::ShippingRateTax, :count).by(2)
      end

      it 'will produce a shipping rate with correct taxes' do
        tax_one = subject.taxes.detect { |tax| tax.tax_rate == tax_rate_one }
        tax_two = subject.taxes.detect { |tax| tax.tax_rate == tax_rate_two }
        expect(tax_one.amount).to eq(shipping_rate.cost * tax_rate_one.amount)
        expect(tax_two.amount).to eq(shipping_rate.cost * tax_rate_two.amount)
      end
    end
  end
end
