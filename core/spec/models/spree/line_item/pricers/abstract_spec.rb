require 'spec_helper'

RSpec.describe Spree::LineItem::Pricers::Abstract do
  let(:line_item) { build_stubbed(:line_item) }

  subject { described_class.new(line_item) }

  it { is_expected.to respond_to(:price) }

  it 'defines two practical errors' do
    expect(described_class::VariantMissing.ancestors).to include(StandardError)
    expect(described_class::CurrencyMissing.ancestors).to include(StandardError)
  end

  it 'assigns line item' do
    expect(subject.line_item).to eq(line_item)
  end

  context 'when calling price' do
    it 'raises a NotImplementedError' do
      expect { subject.price }.to raise_error(NotImplementedError)
    end
  end
end
