# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Price, type: :model do
  describe 'searchable columns' do
    subject { described_class.whitelisted_ransackable_attributes }
    it 'allows searching by variant_id' do
      expect(subject).to include("variant_id")
    end
  end

  describe 'validations' do
    let(:variant) { stub_model Spree::Variant }
    subject { Spree::Price.new variant: variant, amount: amount }

    context 'when the amount is nil' do
      let(:amount) { nil }
      it { is_expected.to be_valid }
    end

    context 'when the amount is less than 0' do
      let(:amount) { -1 }

      it 'has 1 error on amount' do
        subject.valid?
        expect(subject.errors[:amount].size).to eq(1)
      end
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:amount].first).to eq 'must be greater than or equal to 0'
      end
    end

    context 'when the amount is greater than maximum amount' do
      let(:amount) { Spree::Price::MAXIMUM_AMOUNT + 1 }

      it 'has 1 error on amount' do
        subject.valid?
        expect(subject.errors[:amount].size).to eq(1)
      end
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:amount].first).to eq "must be less than or equal to #{Spree::Price::MAXIMUM_AMOUNT}"
      end
    end

    context 'when the amount is between 0 and the maximum amount' do
      let(:amount) { Spree::Price::MAXIMUM_AMOUNT }
      it { is_expected.to be_valid }
    end

    context '#country_iso' do
      subject(:price) { build(:price, country_iso: country_iso) }

      context 'when country iso is nil' do
        let(:country_iso) { nil }

        it { is_expected.to be_valid }
      end

      context 'when country iso is an empty string' do
        let(:country_iso) { "" }

        it { is_expected.to be_valid }
      end

      context 'when country iso is a country code' do
        let!(:country) { create(:country, iso: "DE") }
        let(:country_iso) { "DE" }

        it { is_expected.to be_valid }
      end

      context 'when country iso is not a country code' do
        let(:country_iso) { "ZZ" }

        it { is_expected.not_to be_valid }
      end
    end

    describe "country_iso=" do
      let(:price) { Spree::Price.new(country_iso: "de") }

      it "assigns nil if passed nil" do
        price.country_iso = nil
        expect(price.country_iso).to be_nil
      end
    end

    describe '#country' do
      let!(:country) { create(:country, iso: "DE") }
      let(:price) { create(:price, country_iso: "DE") }

      it 'returns the country object' do
        expect(price.country).to eq(country)
      end
    end
  end

  describe "#currency" do
    let(:variant) { stub_model Spree::Variant }
    subject { Spree::Price.new variant: variant, amount: 10, currency: currency }

    describe "validation" do
      context "with an invalid currency" do
        let(:currency) { "XYZ" }

        it { is_expected.to be_invalid }

        it "has an understandable error message" do
          subject.valid?
          expect(subject.errors.messages[:currency].first).to eq("is not a valid currency code")
        end
      end

      context "with a valid currency" do
        let(:currency) { "USD" }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'scopes' do
    describe '.for_any_country' do
      let(:country) { create(:country) }
      let!(:fallback_price) { create(:price, country_iso: nil) }
      let!(:country_price) { create(:price, country: country) }

      subject { described_class.for_any_country }

      it { is_expected.to include(fallback_price) }
    end
  end

  describe 'net_amount' do
    let(:country) { create(:country, iso: "DE") }
    let(:zone) { create(:zone, countries: [country]) }
    let!(:tax_rate) { create(:tax_rate, included_in_price: true, zone: zone, tax_categories: [variant.tax_category]) }

    let(:variant) { create(:product).master }

    let(:price) { variant.prices.create(amount: 20, country: country) }

    subject { price.net_amount }

    it { is_expected.to eq(BigDecimal(20) / 1.1) }
  end
end
