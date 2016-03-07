require 'spec_helper'

describe Spree::Price, type: :model do
  it { is_expected.to respond_to(:vat_country) }
  it { is_expected.to respond_to(:vat_country_iso) }

  describe '#vat_country' do
    let!(:vat_country) { create(:country, iso: "DE") }
    let(:price) { create(:price, vat_country_iso: "DE", is_default: false) }

    it 'returns the country object' do
      expect(price.vat_country).to eq(vat_country)
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

      it 'has 1 error_on' do
        expect(subject.error_on(:amount).size).to eq(1)
      end
      it 'populates errors' do
        subject.valid?
        expect(subject.errors.messages[:amount].first).to eq 'must be greater than or equal to 0'
      end
    end

    context 'when the amount is greater than maximum amount' do
      let(:amount) { Spree::Price::MAXIMUM_AMOUNT + 1 }

      it 'has 1 error_on' do
        expect(subject.error_on(:amount).size).to eq(1)
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

    context "with default price set" do
      subject { Spree::Price.new(variant: variant, is_default: true, vat_country: vat_country) }

      context "when there is a vat country" do
        let(:vat_country) { create(:country) }

        it { is_expected.not_to be_valid }
      end

      context "when there is no vat country" do
        let(:vat_country) { nil }

        it { is_expected.to be_valid }
      end
    end

    context "with default price not set" do
      subject { Spree::Price.new(variant: variant, is_default: false, vat_country: vat_country) }

      context "when there is a vat country" do
        let(:vat_country) { create(:country) }

        it { is_expected.to be_valid }
      end

      context "when there is no vat country" do
        let(:vat_country) { nil }

        it { is_expected.to be_valid }
      end
    end
  end
end
