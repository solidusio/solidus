require 'spec_helper'

describe Spree::Variant::Pricer::PricingOptions do
  subject { described_class.new }

  context 'constants' do
    it 'defines a DEFAULT_PRICE_ATTRIBUTES constant' do
      expect(described_class).to be_const_defined(:DEFAULT_PRICE_ATTRIBUTES)
    end

    describe 'DEFAULT_PRICE_ATTRIBUTES' do
      it 'can be passed into a WHERE clause on Spree::Prices' do
        expect do
          Spree::Price.where(described_class::DEFAULT_PRICE_ATTRIBUTES).to_a
        end.not_to raise_error
      end
    end
  end

  context ".from_order" do
    let(:order) { build_stubbed(:order) }
    subject { described_class.from_order(order) }

    it "returns the order's currency" do
      expect(subject.desired_attributes[:currency]).to eq(order.currency)
    end
  end

  describe '#desired_attributes' do
    context "when called with no arguments" do
      it "returns the default pricing options" do
        expect(subject.desired_attributes).to eq(described_class::DEFAULT_PRICE_ATTRIBUTES)
      end
    end

    context "when called with a different currency" do
      subject { described_class.new(currency: "EUR") }

      it "returns a Hash with the correct currency" do
        expect(subject.desired_attributes[:currency]).to eq("EUR")
      end

      it "still retains the default attributes" do
        expect(subject.desired_attributes[:is_default]).to eq(true)
      end
    end
  end

  describe "#cache_key" do
    it 'creates a cache key out of the values of the attributes hash' do
      expect(subject.cache_key).to eq("USD/true")
    end

    context "with another currency" do
      subject { described_class.new(currency: "EUR") }
      it 'creates the correct cache key' do
        expect(subject.cache_key).to eq("EUR/true")
      end
    end
  end
end
