require 'spec_helper'

describe Spree::Variant::PricingOptions do
  subject { described_class.new }

  context '.default_price_attributes' do
    it 'can be passed into a WHERE clause on Spree::Prices' do
      expect(Spree::Price.where(described_class.default_price_attributes).to_a).to eq([])
    end

    context "with a matching price present" do
      let!(:price) { create(:price) }

      it 'returns a matching price' do
        expect(Spree::Price.where(described_class.default_price_attributes).to_a).to include(price)
      end
    end
  end

  context ".from_line_item" do
    let(:line_item) { build_stubbed(:line_item, currency: "USD") }
    subject { described_class.from_line_item(line_item) }

    it "returns the order's currency" do
      expect(subject.desired_attributes[:currency]).to eq("USD")
    end
  end

  describe '#desired_attributes' do
    context "when called with no arguments" do
      it "returns the default pricing options" do
        expect(subject.desired_attributes).to eq(described_class.default_price_attributes)
      end
    end

    context "when called with a different currency" do
      subject { described_class.new(currency: "EUR") }

      it "returns a Hash with the correct currency" do
        expect(subject.desired_attributes[:currency]).to eq("EUR")
      end
    end
  end

  describe "#currency" do
    context "when initialized with no currency" do
      it "returns the default currency" do
        expect(Spree::Config.currency).to eq("USD")
        expect(subject.currency).to eq("USD")
      end
    end

    context "when initialized with a different currency" do
      subject { described_class.new(currency: "EUR") }

      it "returns that currency" do
        expect(subject.currency).to eq("EUR")
      end
    end
  end

  describe "#cache_key" do
    it 'creates a cache key out of the values of the attributes hash' do
      expect(subject.cache_key).to eq("USD")
    end

    context "with another currency" do
      subject { described_class.new(currency: "EUR") }
      it 'creates the correct cache key' do
        expect(subject.cache_key).to eq("EUR")
      end
    end
  end
end
