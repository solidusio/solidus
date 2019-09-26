# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TaxRate, type: :model do
  it { is_expected.to respond_to(:shipping_rate_taxes) }

  context '.for_address' do
    let(:germany) { create(:country, iso: "DE") }
    let(:germany_zone) { create(:zone, countries: [germany]) }
    let!(:german_tax) { create(:tax_rate, zone: germany_zone) }
    let(:france) { create(:country, iso: "FR") }
    let(:france_zone) { create(:zone, countries: [france]) }
    let!(:french_tax) { create(:tax_rate, zone: france_zone) }
    let(:eu_zone) { create(:zone, countries: [germany, france]) }
    let!(:eu_tax) { create(:tax_rate, zone: eu_zone) }
    let(:usa) { create(:country, iso: "US") }
    let(:us_zone) { create(:zone, countries: [usa]) }
    let!(:us_tax) { create(:tax_rate, zone: us_zone) }
    let(:new_york) { create(:state, country: usa, state_code: "NY") }
    let(:new_york_zone) { create(:zone, states: [new_york]) }
    let!(:new_york_tax) { create(:tax_rate, zone: new_york_zone) }
    let(:alabama) { create(:state, country: usa, state_code: "AL") }
    let(:alabama_zone) { create(:zone, states: [alabama]) }
    let!(:alabama_tax) { create(:tax_rate, zone: alabama_zone) }

    subject(:rates_for_address) { Spree::TaxRate.for_address(address) }

    context 'when address is in germany' do
      let(:address) { create(:address, country_iso_code: "DE") }
      it { is_expected.to contain_exactly(german_tax, eu_tax) }
    end

    context 'when address is in france' do
      let(:address) { create(:address, country_iso_code: "FR") }
      it { is_expected.to contain_exactly(french_tax, eu_tax) }
    end

    context 'when address is in new york' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "NY") }
      it { is_expected.to contain_exactly(new_york_tax, us_tax) }
    end

    context 'when address is in alabama' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "AL") }
      it { is_expected.to contain_exactly(alabama_tax, us_tax) }
    end

    context 'when address is in alaska' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "AK") }
      it { is_expected.to contain_exactly(us_tax) }
    end
  end

  context ".for_zone" do
    subject(:rates_for_zone) { Spree::TaxRate.for_zone(zone) }

    context "when zone is nil" do
      let(:zone) { nil }

      it "should return an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when no rate zones match the tax zone" do
      let(:rate_zone) { create(:zone, :with_country) }
      let!(:rate) { create :tax_rate, zone: rate_zone }

      context "when there is no default tax zone" do
        context "and the zone has no shared members with the rate zone" do
          let(:zone) { create(:zone, :with_country) }

          it "should return an empty array" do
            expect(subject).to eq([])
          end
        end

        context "and the zone has shared members with the rate zone" do
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return the rate that matches the rate zone" do
            expect(subject).to eq([rate])
          end
        end

        context "there is many rates that match the zone" do
          let!(:rate2) { create :tax_rate, zone: rate_zone }
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return all rates that match the rate zone" do
            expect(subject).to match_array([rate, rate2])
          end
        end

        context "when the tax_zone is contained within a rate zone" do
          let(:country1) { create :country }
          let(:country2) { create :country }
          let(:rate_zone) { create(:zone, countries: [country1, country2]) }
          let(:zone) { create(:zone, countries: [country1]) }

          it "should return the rate zone" do
            expect(subject).to eq([rate])
          end
        end
      end

      context "when there is a default tax zone" do
        let(:default_zone) { create(:zone, :with_country) }
        let(:included_in_price) { false }
        let!(:rate) do
          create(:tax_rate, zone: default_zone, included_in_price: included_in_price)
        end

        context "when the zone is the default zone" do
          let(:zone) { default_zone }

          context "when the tax is not a VAT" do
            it { is_expected.to eq([rate]) }
          end

          context "when the tax is a VAT" do
            let(:included_in_price) { true }

            it { is_expected.to eq([rate]) }
          end
        end

        context "when the zone is outside the default zone" do
          let(:zone) { create(:zone, :with_country) }

          it { is_expected.to be_empty }
        end
      end
    end
  end

  describe "#adjust" do
    let(:taxable_address) { create(:address) }
    let(:order) { create(:order_with_line_items, ship_address: order_address) }
    let(:tax_zone) { create(:zone, countries: [taxable_address.country]) }
    let(:foreign_address) { create(:address, country_iso_code: "CA") }
    let!(:foreign_zone) { create(:zone, countries: [foreign_address.country]) }
    let(:tax_rate) do
      create(:tax_rate,
        included_in_price: included_in_price,
        show_rate_in_label: show_rate_in_label,
        amount: 0.125,
        zone: tax_zone)
    end

    let(:item) { order.line_items.first }

    describe 'adjustments' do
      before do
        expect(Spree::Deprecation).to receive(:warn)
        tax_rate.adjust(nil, item)
      end

      let(:adjustment_label) { item.adjustments.tax.first.label }

      context 'for included rates' do
        let(:included_in_price) { true }
        let(:order_address) { taxable_address }

        context 'with show rate in label' do
          let(:show_rate_in_label) { true }

          it 'shows the rate in the label' do
            expect(adjustment_label).to include("12.500%")
          end

          it 'adds a remark that the rate is included in the price' do
            expect(adjustment_label).to include("Included in Price")
          end
        end

        context 'with show rate in label turned off' do
          let(:show_rate_in_label) { false }

          it 'does not show the rate in the label' do
            expect(adjustment_label).not_to include("12.500%")
          end

          it 'does not have two consecutive spaces' do
            expect(adjustment_label).not_to include("  ")
          end

          it 'adds a remark that the rate is included in the price' do
            expect(adjustment_label).to include("Included in Price")
          end
        end
      end

      context 'for additional rates' do
        let(:included_in_price) { false }
        let(:order_address) { taxable_address }

        context 'with show rate in label' do
          let(:show_rate_in_label) { true }

          it 'shows the rate in the label' do
            expect(adjustment_label).to include("12.500%")
          end

          it 'does not add a remark that the rate is included in the price' do
            expect(adjustment_label).not_to include("Included in Price")
          end
        end

        context 'with show rate in label turned off' do
          let(:show_rate_in_label) { false }

          it 'does not show the rate in the label' do
            expect(adjustment_label).not_to include("12.500%")
          end

          it 'does not add a remark that the rate is included in the price' do
            expect(adjustment_label).not_to include("Included in Price")
          end
        end
      end
    end
  end

  describe "#active?" do
    subject(:rate) { create(:tax_rate, validity).active? }

    context "when validity is not set" do
      let(:validity) { {} }

      it { is_expected.to eq(true) }
    end

    context "when starts_at is set" do
      context "now" do
        let(:validity) { { starts_at: Time.current } }

        it { is_expected.to eq(true) }
      end

      context "in the past" do
        let(:validity) { { starts_at: 1.day.ago } }

        it { is_expected.to eq(true) }
      end

      context "in the future" do
        let(:validity) { { starts_at: 1.day.from_now } }

        it { is_expected.to eq(false) }
      end
    end

    context "when expires_at is set" do
      context "now" do
        let(:validity) { { expires_at: Time.current } }

        it { is_expected.to eq(false) }
      end

      context "in the past" do
        let(:validity) { { expires_at: 1.day.ago } }

        it { is_expected.to eq(false) }
      end

      context "in the future" do
        let(:validity) { { expires_at: 1.day.from_now } }

        it { is_expected.to eq(true) }
      end
    end

    context "when starts_at and expires_at are set" do
      context "so that today is in range" do
        let(:validity) { { starts_at: 1.day.ago, expires_at: 1.day.from_now } }

        it { is_expected.to eq(true) }
      end

      context "both in the past" do
        let(:validity) { { starts_at: 2.days.ago, expires_at: 1.day.ago } }

        it { is_expected.to eq(false) }
      end

      context "both in the future" do
        let(:validity) { { starts_at: 1.day.from_now, expires_at: 2.days.from_now } }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#tax_category (deprecated)' do
    let(:tax_rate) { create(:tax_rate, tax_categories: [tax_category]) }
    let(:tax_category) { create(:tax_category) }

    it "returns the first tax category" do
      tax_category = Spree::Deprecation.silence { tax_rate.tax_category }
      expect(tax_category).to eq(tax_category)
    end
  end

  describe '#tax_category= (deprecated)' do
    let(:tax_rate) { Spree::TaxRate.new }
    let(:tax_category) { create(:tax_category) }

    it "can assign the tax categories" do
      Spree::Deprecation.silence {
        tax_rate.tax_category = tax_category
      }
      expect(tax_rate.tax_categories).to eq([tax_category])
    end
  end
end
