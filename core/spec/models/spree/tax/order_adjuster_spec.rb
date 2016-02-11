require 'spec_helper'

RSpec.describe Spree::Tax::OrderAdjuster do
  subject(:adjuster) { described_class.new(order) }

  describe 'initialization' do
    let(:order) { Spree::Order.new }

    it 'sets order to adjustable' do
      expect(adjuster.order).to eq(order)
    end
  end

  describe '#adjust!' do
    let(:address) { build_stubbed(:address) }
    let(:line_items) { build_stubbed_list(:line_item, 2) }
    let(:order) { build_stubbed(:order, line_items: line_items, ship_address: address) }
    let(:item_adjuster) { Spree::Tax::ItemAdjuster.new(line_items.first) }
    let(:default_address) { Spree::Address.build_default }
    let(:order_wide_options) do
      {
        order_rates: [],
        default_vat_rates: []
      }
    end

    before do
      expect(Spree::Address).to receive(:build_default).and_return(default_address)
      expect(Spree::TaxRate).to receive(:for_address).with(address).and_return([])
      expect(Spree::TaxRate).to receive(:for_address).with(default_address).and_return([])
    end

    it 'calls the item adjuster with all line items' do
      expect(Spree::Tax::ItemAdjuster).to receive(:new)
        .with(line_items.first, order_wide_options)
        .and_return(item_adjuster)
      expect(Spree::Tax::ItemAdjuster).to receive(:new)
        .with(line_items.second, order_wide_options)
        .and_return(item_adjuster)

      expect(item_adjuster).to receive(:adjust!).twice
      adjuster.adjust!
    end
  end
end
