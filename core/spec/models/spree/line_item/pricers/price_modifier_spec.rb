require 'spec_helper'

RSpec.describe Spree::LineItem::Pricers::PriceModifier do
  let(:variant) { create(:variant) }
  let(:currency) { "USD" }
  let(:original_price) { 12.34 }
  let(:options) { {} }
  let(:line_item) do
    build(:line_item, variant: variant, currency: currency, price: original_price)
  end

  subject { described_class.new(line_item, options).price }

  context 'with no variant present' do
    let(:variant) { nil }

    it 'raises VariantMissing' do
      expect { subject }.to raise_error(described_class::VariantMissing)
    end
  end

  context 'with no currency present' do
    let(:currency) { nil }

    it 'raises CurrencyMissing' do
      expect { subject }.to raise_error(described_class::CurrencyMissing)
    end
  end

  shared_examples_for 'it prices the line item no matter what' do
    it 'returns the variant price in USD' do
      expect(subject).to eq(variant.default_price.money)
    end

    context 'with price modifiers in the options' do
      let(:options) { { gift_wrap: true } }

      before do
        expect(variant).to receive(:gift_wrap_price_modifier_amount_in).with(currency, true).and_return(2.00)
      end

      it 'returns the variant price plus price modifiers' do
        expect(subject).to eq(Spree::Money.new(variant.price + 2))
      end
    end
  end

  context 'with no price present' do
    let(:original_price) { nil }

    it_behaves_like 'it prices the line item no matter what'
  end

  context 'with a price present' do
    it_behaves_like 'it prices the line item no matter what'
  end
end
