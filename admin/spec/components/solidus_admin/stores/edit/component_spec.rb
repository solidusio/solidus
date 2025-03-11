# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Stores::Edit::Component, type: :component do
  let(:store) { build(:store, id: 1, name: "Test Store") }
  let(:component) { described_class.new(store: store) }

  describe "#render" do
    it "renders the edit store form with existing data" do
      store = Spree::Store.create!(name: "Test Store", url: "test-store.com", code: 'test-store', mail_from_address: 'test@mail.co')
      render_inline described_class.new(store: store)

      expect(rendered_content).to have_selector("form")
      expect(rendered_content).to have_field("store[name]", with: "Test Store")
      expect(rendered_content).to have_field("store[url]", with: "test-store.com")
      expect(rendered_content).to have_field("store[code]", with: "test-store")
      expect(rendered_content).to have_field("store[mail_from_address]", with: "test@mail.co")
    end
  end

  describe "#form_id" do
    it "returns a unique form id based on the store" do
      expect(component.form_id).to match(/stores--edit--form-1/)
    end
  end

  describe "#currency_options" do
    it "returns the available currencies" do
      allow(Spree::Config).to receive(:available_currencies).and_return([Money::Currency.new("USD"), Money::Currency.new("EUR")])

      expect(component.currency_options).to contain_exactly("USD", "EUR")
    end
  end

  describe "#cart_tax_country_options" do
    it "returns available countries for cart tax selection" do
      country = create(:country, name: "United States of America", iso: "US")
      allow(Spree::Country).to receive(:available).and_return([country])

      expect(component.cart_tax_country_options).to include(["United States of America", "US"])
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
    it "returns a list of available countries" do
      country = create(:country, name: "United States", id: 1)
      allow(Spree::Country).to receive(:order).and_return([country])

      expect(component.available_country_options).to include(["United States", 1])
    end
  end
end
