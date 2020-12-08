# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Tax::TaxHelpers do
  before do
    stub_const('DummyClass', (Class.new do
      include Spree::Tax::TaxHelpers

      def valid_rates(item)
        rates_for_item(item)
      end
    end))
  end

  let(:tax_category) { create(:tax_category) }
  let(:irrelevant_tax_category) { create(:tax_category) }

  let(:item) { create(:line_item, tax_category: tax_category) }
  let(:tax_address) { item.order.tax_address }
  let(:zone) { create(:zone, name: "Country Zone", countries: [tax_address.country]) }

  let!(:tax_rate) do
    create(:tax_rate, tax_categories: [tax_category], zone: zone)
  end

  describe '#rates_for_item' do
    it 'returns tax rates that match the tax category of the given item' do
      expect(DummyClass.new.valid_rates(item)).to contain_exactly(tax_rate)
    end

    context 'when multiple rates exist that are currently not valid' do
      let(:starts_at) { 1.day.from_now }
      let(:expires_at) { 2.days.from_now }

      let!(:invalid_tax_rate) do
        create(:tax_rate, tax_categories: [tax_category], zone: zone,
               starts_at: starts_at, expires_at: expires_at)
      end

      it 'returns only active rates that match the tax category of given item' do
        expect(Spree::TaxRate.for_address(tax_address)).to contain_exactly(tax_rate, invalid_tax_rate)

        expect(DummyClass.new.valid_rates(item)).to contain_exactly(tax_rate)
      end
    end
  end
end
