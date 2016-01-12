require 'spec_helper'

RSpec.describe Spree::Tax::ItemAdjuster do
  subject(:adjuster) { described_class.new(item) }
  let(:order) { Spree::Order.new }
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
    it 'calls Spree::TaxRate.adjust' do
      expect(Spree::TaxRate).to receive(:adjust)
      adjuster.adjust!
    end
  end
end
