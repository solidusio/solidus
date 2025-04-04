# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Stores::New::Component, type: :component do
  let(:store) { Spree::Store.new }
  let(:component) { described_class.new(store: store) }

  describe "#render" do
    it "renders the new store form" do
      store = Spree::Store.new
      render_inline described_class.new(store: store)

      expect(rendered_content).to have_selector("form")
      expect(rendered_content).to have_field("store[name]")
      expect(rendered_content).to have_field("store[url]")
    end
  end

  describe "#form_id" do
    it "generates a unique form ID for the store" do
      expect(component.form_id).to match(/--form-/)
    end
  end

  describe "#currency_options" do
    it "returns a list of available currency ISO codes" do
      allow(Spree::Config).to receive(:available_currencies).and_return([Money::Currency.new("USD"), Money::Currency.new("EUR")])
      expect(component.currency_options).to contain_exactly("USD", "EUR")
    end
  end

  describe "#cart_tax_country_options" do
    it "returns an array of available tax country names and ISO codes" do
      country = create(:country, name: "United States", iso: "US")
      allow(component).to receive(:fetch_available_countries).and_return([country])
      expect(component.cart_tax_country_options).to include(["United States", "US"])
    end
  end

  describe "#localization_options" do
    it "returns available locales with translated names" do
      allow(Spree).to receive(:i18n_available_locales).and_return([:en, :fr])
      expect(component.localization_options).to include(["English (US)", :en])
      expect(component.localization_options).to include(["English (US)", :fr])
    end
  end

  describe "#available_country_options" do
    it "returns a list of available countries sorted by name" do
      country1 = create(:country, name: "Germany", id: 1)
      country2 = create(:country, name: "France", id: 2)
      allow(Spree::Country).to receive(:order).and_return([country1, country2])
      expect(component.available_country_options).to eq([["Germany", 1], ["France", 2]])
    end
  end
end
