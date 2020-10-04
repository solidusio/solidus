# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Variant::PricingOptions do
  subject { described_class.new }

  context '.default_price_attributes' do
    subject { described_class.default_price_attributes }

    it { is_expected.to have_key(:currency) }
    it { is_expected.to have_key(:country_iso) }

    it 'can be passed into a WHERE clause on Spree::Prices' do
      expect(Spree::Price.where(subject).to_a).to eq([])
    end

    context "with a matching price present" do
      let!(:price) { create(:price) }

      it 'returns a matching price' do
        expect(Spree::Price.where(subject).to_a).to include(price)
      end
    end
  end

  context ".from_line_item" do
    let(:line_item) { build_stubbed(:line_item) }
    subject { described_class.from_line_item(line_item) }

    it "returns the order's currency" do
      expect(subject.desired_attributes[:currency]).to eq("USD")
    end

    it "takes the orders tax address country" do
      expect(subject.desired_attributes[:country_iso]).to eq("US")
    end

    context 'if order has no currency' do
      before do
        expect(line_item.order).to receive(:currency).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
      end

      it "returns the configured default currency" do
        expect(subject.desired_attributes[:currency]).to eq("RUB")
      end
    end

    context "if line item has no order" do
      before do
        expect(line_item).to receive(:order).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
      end

      it "returns the configured default currency" do
        expect(subject.desired_attributes[:currency]).to eq("RUB")
      end
    end
  end

  context ".from_price" do
    let(:country) { create(:country) }
    let(:price) { create(:price, country: country) }

    subject { described_class.from_price(price) }
    it "gets the currency from the previous price" do
      expect(subject.currency).to eq(price.currency)
      expect(subject.country_iso).to eq(country.iso)
    end
  end

  context ".from_context" do
    let(:view_context) { double(ApplicationController, current_store: store) }
    subject { described_class.from_context(view_context) }

    context "if the store has not defined default_currency" do
      let(:store) { FactoryBot.create :store, default_currency: nil, cart_tax_country_iso: nil }

      it "fallbacks to Spree::Config.currency" do
        expect(Spree::Variant::PricingOptions).to receive(:new).with(currency: Spree::Config.currency, country_iso: nil)
        expect(subject).to be_nil
      end
    end

    context 'if the store has default_currency and cart_tax_country_iso' do
      let(:store) { FactoryBot.create :store, default_currency: 'MXN' }

      it "uses current_store information" do
        expect(Spree::Variant::PricingOptions).to receive(:new).with(currency: store.default_currency, country_iso: store.cart_tax_country_iso)
        expect(subject).to be_nil
      end
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

    context "when called with a different country_iso" do
      subject { described_class.new(country_iso: "DE") }

      it "returns a Hash with the correct country" do
        expect(subject.desired_attributes[:country_iso]).to eq("DE")
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

  describe "#country_iso" do
    context "when initialized with no country_iso" do
      it "returns the default country_iso" do
        expect(Spree::Config).to receive(:admin_vat_country_iso).and_return("US")
        expect(subject.country_iso).to eq("US")
      end
    end

    context "when initialized with a different country_iso" do
      subject { described_class.new(country_iso: "DE") }

      it "returns that country_iso" do
        expect(subject.country_iso).to eq("DE")
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

      context "and another country" do
        subject { described_class.new(currency: "EUR", country_iso: "DE") }

        it 'creates the correct cache key' do
          expect(subject.cache_key).to eq("EUR/DE")
        end
      end
    end
  end

  describe "#search_arguments" do
    let!(:price) { create(:price, currency: "EUR") }
    let(:options) { {} }

    subject { described_class.new(options).search_arguments }

    context "with a currency given" do
      let(:options) { { currency: "EUR" } }

      it 'can be passed into a `where` clause' do
        expect(Spree::Price.where(subject)).to eq([price])
      end
    end

    context "with no country given" do
      it "is an array with only nil inside" do
        expect(subject[:country_iso]).to eq([nil])
      end
    end

    context "with a country given" do
      let(:options) { { country_iso: "DE" } }

      it "is an array with the country and nil" do
        expect(subject[:country_iso]).to eq(["DE", nil])
      end
    end
  end
end
