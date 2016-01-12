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
    let(:order) { Spree::Order.new }

    it 'calls the Spree::TaxRate.adjust' do
      expect(Spree::TaxRate).to receive(:adjust)
      adjuster.adjust!
    end
  end
end
