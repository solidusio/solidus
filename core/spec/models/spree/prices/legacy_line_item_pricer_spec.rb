require 'spec_helper'

RSpec.describe Spree::Prices::LegacyLineItemPricer do
  describe '.set_price_for' do
    subject { described_class.set_price_for(line_item) }

    it 'responds to .set_price_for' do
      expect(described_class).to respond_to(:set_price_for)
    end

    context 'when called with a line item without a variant' do
      let(:line_item) { Spree::LineItem.new }

      it 'will raise a variant missing error' do
        expect { subject }.to raise_error(Spree::Prices::LegacyLineItemPricer::VariantRequired)
      end
    end

    context 'when called with a line item with a variant' do
      let(:line_item) { build(:line_item) }

      it 'will return the same line item' do
        expect(subject.object_id).to eq(line_item.object_id)
      end
    end

    context 'when called with a line item without a currency' do
      let(:line_item) { build(:line_item, currency: nil) }

      it 'will return that line item with the orders currency' do
        expect(line_item.order.currency).to be_present
        expect(subject.currency).to eq(line_item.order.currency)
      end
    end

    context 'when called with a line item without a price' do
      let(:line_item) { build(:line_item, price: nil) }

      it 'will return that line item with the variants price' do
        expect(subject.price).to eq(line_item.variant.price)
      end
    end

    context 'when called with a line item that has a price' do
      let(:line_item) { build(:line_item, price: 20_000) }

      it 'will not change the price of the line item' do
        expect(line_item.price).to eq(20_000)
      end
    end
  end
end
