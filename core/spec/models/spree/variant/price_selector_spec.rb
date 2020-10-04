# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Variant::PriceSelector do
  let(:variant) { build_stubbed(:variant) }

  subject { described_class.new(variant) }

  it { is_expected.to respond_to(:variant) }
  it { is_expected.to respond_to(:price_for) }

  describe ".pricing_options_class" do
    it "returns the standard pricing options class" do
      expect(described_class.pricing_options_class).to eq(Spree::Variant::PricingOptions)
    end
  end

  describe "#price_for(options)" do
    let(:variant) { create(:variant, price: 12.34) }

    context "with the default currency" do
      let(:pricing_options) { described_class.pricing_options_class.new(currency: "USD") }

      it "returns the correct (default) price as a Spree::Money object" do
        expect(subject.price_for(pricing_options)).to eq(Spree::Money.new(12.34, currency: "USD"))
      end

      context "with the another country iso" do
        let(:country) { create(:country, iso: "DE") }

        let(:pricing_options) do
          described_class.pricing_options_class.new(currency: "USD", country_iso: "DE")
        end

        context "with a price for that country present" do
          before do
            variant.prices.create(amount: 44.44, country: country, currency: Spree::Config.currency)
          end

          it "returns the correct price" do
            expect(subject.price_for(pricing_options)).to eq(Spree::Money.new(44.44, currency: "USD"))
          end
        end

        context "with no price for that country present" do
          context "and no fallback price for the variant present" do
            before do
              variant.prices.delete_all
            end

            it "returns nil" do
              expect(subject.price_for(pricing_options)).to be_nil
            end
          end

          context "and a fallback price for the variant present" do
            before do
              variant.prices.create(amount: 55.44, country: nil, currency: Spree::Config.currency)
            end

            it "returns the fallback price" do
              expect(subject.price_for(pricing_options)).to eq(Spree::Money.new(55.44, currency: "USD"))
            end
          end
        end
      end
    end

    context "with a different currency" do
      let(:pricing_options) { described_class.pricing_options_class.new(currency: "EUR") }

      context "when there is a price for that currency" do
        before do
          variant.prices.create(amount: 99.00, currency: "EUR")
        end

        it "returns the price in the correct currency as a Spree::Money object" do
          expect(subject.price_for(pricing_options)).to eq(Spree::Money.new(99.00, currency: "EUR"))
        end
      end

      context "when there is no price for that currency" do
        it "returns nil" do
          expect(subject.price_for(pricing_options)).to be_nil
        end
      end
    end
  end
end
