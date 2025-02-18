# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::TaxRate, type: :model do
  it { is_expected.to respond_to(:shipping_rate_taxes) }

  context ".for_address" do
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

    context "when address is in germany" do
      let(:address) { create(:address, country_iso_code: "DE") }
      it { is_expected.to contain_exactly(german_tax, eu_tax) }
    end

    context "when address is in france" do
      let(:address) { create(:address, country_iso_code: "FR") }
      it { is_expected.to contain_exactly(french_tax, eu_tax) }
    end

    context "when address is in new york" do
      let(:address) { create(:address, country_iso_code: "US", state_code: "NY") }
      it { is_expected.to contain_exactly(new_york_tax, us_tax) }
    end

    context "when address is in alabama" do
      let(:address) { create(:address, country_iso_code: "US", state_code: "AL") }
      it { is_expected.to contain_exactly(alabama_tax, us_tax) }
    end

    context "when address is in alaska" do
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
          create(:tax_rate, zone: default_zone, included_in_price:)
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

  context ".active" do
    subject(:active_tax_rates) { Spree::TaxRate.active }

    context "when the tax rate has no start or expiry date" do
      let!(:rate) { create(:tax_rate) }

      it { is_expected.to eq([rate]) }
    end

    context "when the start date is in the past" do
      let!(:rate) { create(:tax_rate, starts_at: 1.day.ago) }

      it { is_expected.to eq([rate]) }
    end

    context "when the start date is in the future" do
      let!(:rate) { create(:tax_rate, starts_at: 1.day.from_now) }

      it { is_expected.to be_empty }
    end

    context "when the expiry date is in the future" do
      let!(:rate) { create(:tax_rate, expires_at: 1.day.from_now) }

      it { is_expected.to eq([rate]) }
    end

    context "when the expiry date is in the past" do
      let!(:rate) { create(:tax_rate, expires_at: 1.day.ago) }

      it { is_expected.to be_empty }
    end

    context "when the start date in the past and expiry date is in the future" do
      let!(:rate) { create(:tax_rate, starts_at: 1.day.ago, expires_at: 1.day.from_now) }

      it { is_expected.to eq([rate]) }
    end

    context "when the start date and expiry date are in the past" do
      let!(:rate) { create(:tax_rate, starts_at: 1.day.ago, expires_at: 1.day.ago) }

      it { is_expected.to be_empty }
    end

    context "when the start date and expiry date are in the future" do
      let!(:rate) { create(:tax_rate, starts_at: 1.day.from_now, expires_at: 1.day.from_now) }

      it { is_expected.to be_empty }
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
        let(:validity) { {starts_at: Time.current} }

        it { is_expected.to eq(true) }
      end

      context "in the past" do
        let(:validity) { {starts_at: 1.day.ago} }

        it { is_expected.to eq(true) }
      end

      context "in the future" do
        let(:validity) { {starts_at: 1.day.from_now} }

        it { is_expected.to eq(false) }
      end
    end

    context "when expires_at is set" do
      context "now" do
        let(:validity) { {expires_at: Time.current} }

        it { is_expected.to eq(false) }
      end

      context "in the past" do
        let(:validity) { {expires_at: 1.day.ago} }

        it { is_expected.to eq(false) }
      end

      context "in the future" do
        let(:validity) { {expires_at: 1.day.from_now} }

        it { is_expected.to eq(true) }
      end
    end

    context "when starts_at and expires_at are set" do
      context "so that today is in range" do
        let(:validity) { {starts_at: 1.day.ago, expires_at: 1.day.from_now} }

        it { is_expected.to eq(true) }
      end

      context "both in the past" do
        let(:validity) { {starts_at: 2.days.ago, expires_at: 1.day.ago} }

        it { is_expected.to eq(false) }
      end

      context "both in the future" do
        let(:validity) { {starts_at: 1.day.from_now, expires_at: 2.days.from_now} }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe "#display_amount" do
    subject(:rate) { create(:tax_rate, amount: 0.1).display_amount }

    it { is_expected.to eq("10.0%") }
  end
end
