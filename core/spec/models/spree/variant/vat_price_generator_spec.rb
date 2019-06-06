# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Variant::VatPriceGenerator do
  let(:tax_category) { create(:tax_category) }
  let(:product) { variant.product }
  let(:variant) { create(:variant, price: 10, tax_category: tax_category) }

  subject { described_class.new(variant).run }

  context "with Germany as default admin country" do
    let(:germany) { create(:country, iso: "DE") }
    let(:germany_zone) { create(:zone, countries: [germany]) }
    let!(:german_vat) { create(:tax_rate, included_in_price: true, amount: 0.19, zone: germany_zone, tax_categories: [tax_category]) }
    let(:france) { create(:country, iso: "FR") }
    let(:france_zone) { create(:zone, countries: [france]) }
    let!(:french_vat) { create(:tax_rate, included_in_price: true, amount: 0.20, zone: france_zone, tax_categories: [tax_category]) }

    before do
      stub_spree_preferences(admin_vat_country_iso: "DE")
    end

    it "builds a correct price including VAT for all VAT countries" do
      subject
      variant.save
      variant.reload
      expect(variant.default_price.for_any_country?).to be false
      expect(variant.prices.detect { |p| p.country_iso == "DE" }.try!(:amount)).to eq(10.00)
      expect(variant.prices.detect { |p| p.country_iso == "FR" }.try!(:amount)).to eq(10.08)
      expect(variant.prices.detect { |p| p.country_iso.nil? }.try!(:amount)).to eq(8.40)
    end

    it "will not build prices that are already present" do
      expect { subject }.not_to change { variant.prices.length }
    end

    # We need to remove the price for FR from the database so it is created in memory, and then run VatPriceGenerator twice to trigger the duplicate price issue.
    it "will not build duplicate prices on multiple runs" do
      variant.prices.where(country_iso: "FR").each(&:really_destroy!)
      variant.reload
      described_class.new(variant).run
      expect { subject }.not_to change { variant.prices.size }
    end
  end

  context "with no default admin country" do
    let(:germany) { create(:country, iso: "DE") }
    let(:germany_zone) { create(:zone, countries: [germany]) }
    let!(:german_vat) { create(:tax_rate, included_in_price: true, amount: 0.19, zone: germany_zone, tax_categories: [tax_category]) }
    let(:france) { create(:country, iso: "FR") }
    let(:france_zone) { create(:zone, countries: [france]) }
    let!(:french_vat) { create(:tax_rate, included_in_price: true, amount: 0.20, zone: france_zone, tax_categories: [tax_category]) }

    it "builds a correct price including VAT for all VAT countries" do
      subject
      variant.save
      variant.reload
      expect(variant.default_price.for_any_country?).to be true
      expect(variant.prices.detect { |p| p.country_iso == "DE" }.try!(:amount)).to eq(11.90)
      expect(variant.prices.detect { |p| p.country_iso == "FR" }.try!(:amount)).to eq(12.00)
      expect(variant.prices.detect { |p| p.country_iso.nil? }.try!(:amount)).to eq(10.00)
    end
  end

  context "for a variant with not tax category" do
    let(:tax_category) { nil }

    before do
      product.update(tax_category: nil)
    end

    it "creates no addditional prices" do
      expect { subject }.not_to change { variant.prices.length }
    end
  end
end
