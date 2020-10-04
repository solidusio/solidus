# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Variant scopes", type: :model do
  let!(:product) { create(:product) }
  let!(:variant_1) { create(:variant, product: product) }
  let!(:variant_2) { create(:variant, product: product) }

  context ".with_prices" do
    context "when searching for the default pricing options" do
      it "finds all variants" do
        expect(Spree::Variant.with_prices).to contain_exactly(product.master, variant_1, variant_2)
      end
    end

    context "when searching for different pricing options" do
      let(:pricing_options) { Spree::Config.pricing_options_class.new(currency: "EUR") }
      context "when only one variant has price in Euro" do
        before do
          variant_1.prices.create(amount: 99.00, currency: "EUR")
        end

        context "and we search for variants with only prices in Euro" do
          it "finds the one variant with a price in Euro" do
            expect(Spree::Variant.with_prices(pricing_options)).to contain_exactly(variant_1)
          end
        end
      end
    end

    context 'when searching for a variant that has two eligible prices (one fallback)' do
      let(:france) { create(:country, iso: "FR") }
      let(:pricing_options) { Spree::Variant::PricingOptions.new(country_iso: "FR", currency: "EUR") }

      subject { Spree::Variant.with_prices(pricing_options) }

      before do
        variant_1.prices.create!(currency: "EUR", country: france, amount: 10)
        variant_1.prices.create!(currency: "EUR", country: nil, amount: 10)
      end

      it { is_expected.to eq([variant_1]) }
    end
  end

  it ".descend_by_popularity" do
    # Requires a product with at least two variants, where one has a higher number of
    # orders than the other
    Spree::LineItem.delete_all # FIXME leaky database - too many line_items
    create(:line_item, variant: variant_1)
    expect(Spree::Variant.descend_by_popularity.first).to eq(variant_1)
  end

  context "finding by option values" do
    let!(:option_type) { create(:option_type, name: "bar") }
    let!(:option_value_1) do
      option_value = create(:option_value, name: "foo", option_type: option_type)
      variant_1.option_values << option_value
      option_value
    end

    let!(:option_value_2) do
      option_value = create(:option_value, name: "fizz", option_type: option_type)
      variant_1.option_values << option_value
      option_value
    end

    let!(:product_variants) { product.variants_including_master }

    it "by objects" do
      variants = product_variants.has_option(option_type, option_value_1)
      expect(variants).to include(variant_1)
      expect(variants).not_to include(variant_2)
    end

    it "by names" do
      variants = product_variants.has_option("bar", "foo")
      expect(variants).to include(variant_1)
      expect(variants).not_to include(variant_2)
    end

    it "by ids" do
      variants = product_variants.has_option(option_type.id, option_value_1.id)
      expect(variants).to include(variant_1)
      expect(variants).not_to include(variant_2)
    end

    it "by mixed conditions" do
      variants = product_variants.has_option(option_type.id, "foo", option_value_2)
      expect(variants).to be_empty
    end
  end
end
