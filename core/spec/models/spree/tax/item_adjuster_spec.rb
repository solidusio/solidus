require 'spec_helper'

RSpec.describe Spree::Tax::ItemAdjuster do
  subject(:adjuster) { described_class.new(item) }
  let(:order) { create(:order) }
  let(:item) { Spree::LineItem.new(order: order) }

  before do
    allow(order).to receive(:tax_zone) { build(:zone) }
  end

  describe 'initialization' do
    it 'sets order to item order' do
      expect(adjuster.order).to eq(item.order)
    end

    it 'sets adjustable' do
      expect(adjuster.item).to eq(item)
    end
  end

  describe '#adjust!' do
    before do
      expect(order).to receive(:tax_zone).and_return(tax_zone)
    end

    context 'when the order has no tax zone' do
      let(:tax_zone) { nil }

      before do
        allow(order).to receive(:tax_zone).and_return(nil)
        adjuster.adjust!
      end

      it 'returns nil early' do
        expect(adjuster.adjust!).to be_nil
      end
    end

    context 'when the order has a tax zone' do
      let(:item) { build_stubbed :line_item, order: order }
      let(:tax_zone) { build_stubbed(:zone, :with_country) }

      before do
        expect(Spree::TaxRate).to receive(:for_zone).with(tax_zone).and_return(rates_for_order_zone)
        expect(Spree::TaxRate).to receive(:for_zone).with(Spree::Zone.default_tax).and_return([])
      end

      context 'when there are no matching rates' do
        let(:rates_for_order_zone) { [] }

        it 'returns no adjustments' do
          expect(adjuster.adjust!).to eq([])
        end
      end

      context 'when there are matching rates for the zone' do
        context 'and all rates have the same tax category as the item' do
          let(:item_tax_category) { build_stubbed(:tax_category) }
          let(:rate_1) { create :tax_rate, tax_category: item_tax_category }
          let(:rate_2) { create :tax_rate }
          let(:rates_for_order_zone) { [rate_1, rate_2] }

          before { allow(item).to receive(:tax_category).and_return(item_tax_category) }

          it 'creates an adjustment for every matching rate' do
            expect(adjuster.adjust!.length).to eq(1)
          end
        end
      end
    end
  end
end
