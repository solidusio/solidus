# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Store, type: :model do
  it { is_expected.to respond_to(:cart_tax_country_iso) }

  describe ".default" do
    it "should ensure saved store becomes default if one doesn't exist yet" do
      expect(Spree::Store.where(default: true).count).to eq(0)
      store = build(:store)
      expect(store.default).not_to be true

      store.save!

      expect(store.default).to be true
    end

    it "should ensure there is only one default" do
      orig_default_store = create(:store, default: true)
      expect(orig_default_store.reload.default).to be true

      new_default_store = create(:store, default: true)

      expect(Spree::Store.where(default: true).count).to eq(1)

      [orig_default_store, new_default_store].each(&:reload)

      expect(new_default_store.default).to be true
      expect(orig_default_store.default).not_to be true
    end
  end

  describe "#default_cart_tax_location" do
    subject { described_class.new(cart_tax_country_iso:) }
    context "when there is no cart_tax_country_iso set" do
      let(:cart_tax_country_iso) { "" }
      it "responds with an empty default_cart_tax_location" do
        expect(subject.default_cart_tax_location).to be_empty
      end
    end

    context "when there is a cart_tax_country_iso set" do
      let(:country) { create(:country, iso: "DE") }
      let(:cart_tax_country_iso) { country.iso }

      it "responds with a default_cart_tax_location with that country" do
        expect(subject.default_cart_tax_location).to eq(Spree::Tax::TaxLocation.new(country:))
      end
    end
  end

  describe "#available_locales" do
    let(:store) { described_class.new(available_locales: locales) }
    subject { store.available_locales }

    context "with available_locales: []" do
      let(:locales) { [] }

      it "returns all available locales" do
        expect(subject).to eq([:en])
      end

      it "serializes as nil" do
        expect(store[:available_locales]).to be nil
      end
    end

    context "with available_locales: [:en]" do
      let(:locales) { [:en] }

      it "returns [:en]" do
        expect(subject).to eq([:en])
      end

      it "serializes correctly" do
        expect(store[:available_locales]).to eq("en")
      end
    end

    context "with available_locales: [:en, :fr]" do
      let(:locales) { [:en, :fr] }

      it "returns [:fr]" do
        expect(subject).to eq([:en, :fr])
      end

      it "serializes correctly" do
        expect(store[:available_locales]).to eq("en,fr")
      end
    end

    context "with available_locales: [:fr]" do
      let(:locales) { [:fr] }

      it "returns [:fr]" do
        expect(subject).to eq([:fr])
      end
    end

    context 'with available_locales: ["fr"]' do
      let(:locales) { ["fr"] }

      it "returns symbols [:fr]" do
        expect(subject).to eq([:fr])
      end
    end
  end

  describe "enum reverse_charge_status" do
    it "defines the expected enum values" do
      expect(Spree::Store.reverse_charge_statuses).to eq({
        "disabled" => 0,
        "enabled" => 1,
        "not_validated" => 2
      })
    end

    it "allows valid values" do
      store = build(:store)
      # Updates the reverse_charge_status to "not_validated"
      expect(store).to be_valid
      store.reverse_charge_status_not_validated!

      # Updates the reverse_charge_status to "disabled"
      expect(store).to be_valid
      store.reverse_charge_status_disabled!
      expect(store).to be_valid

      # Updates the reverse_charge_status to "enabled"
      store.reverse_charge_status_enabled!
      expect(store).to be_valid
    end

    it "raises an error for invalid values" do
      expect { Spree::Store.new(reverse_charge_status: :invalid_status) }.to raise_error(ArgumentError)
    end
  end
end
