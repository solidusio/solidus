require 'spec_helper'

RSpec.describe Spree::Tax::ItemAdjuster do
  subject(:adjuster) { described_class.new(item) }
  let(:order) { Spree::Order.new }
  let(:item) { Spree::LineItem.new(order: order) }

  describe 'initialization' do
    it 'sets order to item order' do
      expect(adjuster.order).to eq(item.order)
    end

    it 'sets adjustable' do
      expect(adjuster.item).to eq(item)
    end
  end

  describe '#adjust!' do
    let(:order) { Spree::Order.new(ship_address: address) }

    context 'when the order has no tax address' do
      let(:item) { create :line_item, order: order }
      let(:address) { nil }

      before do
        adjuster.adjust!
      end
      it 'returns nil early' do
        pending "this requires an empty? method on Spree::TaxLocation"
        expect(adjuster.adjust!).to be_nil
      end
    end

    context 'when the order has a tax address' do
      let(:item) { create :line_item, order: order }
      let(:address) { create(:address) }

      before do
        expect(Spree::TaxRate).to receive(:for_address)
                                    .with(address)
                                    .at_least(:once)
                                    .and_return(order_rates)
        expect(Spree::TaxRate).to receive(:for_address)
                                    .with(Spree::Config.default_tax_location)
                                    .at_least(:once)
                                    .and_return([])
      end

      context 'when there are no matching rates' do
        let(:order_rates) { [] }

        it 'returns no adjustments' do
          expect(adjuster.adjust!).to eq([])
        end
      end

      context 'when there are matching rates for the zone' do
        context 'and all rates have the same tax category as the item' do
          let(:item_tax_category) { build_stubbed(:tax_category) }
          let(:rate_1) { create :tax_rate, tax_category: item_tax_category }
          let(:rate_2) { create :tax_rate }
          let(:order_rates) { [rate_1, rate_2] }

          before { allow(item).to receive(:tax_category).and_return(item_tax_category) }

          it 'creates an adjustment for every matching rate' do
            expect(rate_1).to receive_message_chain(:adjustments, :create!)
            expect(adjuster.adjust!.length).to eq(1)
          end
        end
      end
    end
  end
end
