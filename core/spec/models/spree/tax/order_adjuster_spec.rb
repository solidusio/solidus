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
    let(:zone) { build_stubbed(:zone) }
    let(:line_items) { build_stubbed_list(:line_item, 2) }
    let(:order) { build_stubbed(:order, line_items: line_items) }
    let(:rates_for_order_zone) { [] }
    let(:item_adjuster) { Spree::Tax::ItemAdjuster.new(line_items.first) }

    before do
      expect(order).to receive(:tax_zone).at_least(:once).and_return(zone)
      expect(Spree::TaxRate).to receive(:for_zone).with(zone).and_return(rates_for_order_zone)
      expect(Spree::TaxRate).to receive(:for_zone).with(Spree::Zone.default_tax).and_return([])
    end

    it 'calls the item adjuster with all line items' do
      expect(Spree::Tax::ItemAdjuster).to receive(:new).
                                            with(
                                              line_items.first,
                                              rates_for_order_zone: rates_for_order_zone,
                                              rates_for_default_zone: [],
                                              order_tax_zone: zone,
                                            ).and_return(item_adjuster)
      expect(Spree::Tax::ItemAdjuster).to receive(:new).
                                            with(
                                              line_items.second,
                                              rates_for_order_zone: rates_for_order_zone,
                                              rates_for_default_zone: [],
                                              order_tax_zone: zone,
                                            ).and_return(item_adjuster)

      expect(item_adjuster).to receive(:adjust!).twice
      adjuster.adjust!
    end
  end
end
