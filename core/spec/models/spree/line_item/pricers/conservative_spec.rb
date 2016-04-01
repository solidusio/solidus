require 'spec_helper'

RSpec.describe Spree::LineItem::Pricers::Conservative do
  let(:variant) { build_stubbed(:variant) }
  let(:currency) { "EUR" }
  let(:original_price) { 1_000_001.00 }
  let(:original_money_price) { Spree::Money.new(original_price, currency: currency) }
  let(:line_item) do
    build_stubbed(:line_item, price: original_price, variant: variant, currency: currency)
  end

  subject { described_class.new(line_item).price }

  context 'for a line item that has a price' do
    let(:original_price) { 1_000_001.00 }

    it { is_expected.to eq(original_money_price) }

    context 'if it has no variant' do
      let(:variant) { nil }

      it { is_expected.to eq(original_money_price) }
    end

    context 'if it has no currency' do
      let(:currency) { nil }

      it 'raises CurrencyMissing' do
        expect { subject }.to raise_error(described_class::CurrencyMissing)
      end
    end
  end

  context 'for a line item with no price' do
    let(:original_price) { nil }

    it { is_expected.to eq(Spree::Money.new(line_item.variant.amount_in("USD"), currency: 'USD')) }

    context 'for a line item with no variant' do
      let(:variant) { nil }

      it 'raises VariantMissing' do
        expect { subject }.to raise_error(described_class::VariantMissing)
      end
    end

    context 'for a line item with no currency' do
      let(:currency) { nil }

      it 'raises CurrencyMissing' do
        expect { subject }.to raise_error(described_class::CurrencyMissing)
      end
    end
  end
end
