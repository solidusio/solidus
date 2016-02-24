require 'spec_helper'

describe Spree::Tax::ShippingRateTaxer do
  let(:shipping_rate) { build_stubbed(:shipping_rate) }

  subject(:taxer) { described_class.new(shipping_rate) }

  describe '#tax' do
    subject(:taxer) { described_class.new.tax(shipping_rate) }

    context 'with no matching tax rates' do
      it 'returns the object' do
        expect(subject).to eq(shipping_rate)
        expect(subject.taxes).to eq([])
      end
    end
  end
end
