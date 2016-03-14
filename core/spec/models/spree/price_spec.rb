require 'spec_helper'

describe Spree::Price, type: :model do
  it { is_expected.to respond_to(:valid_from) }

  describe 'scopes' do
    describe '.valid_before(date)' do
      let(:variant) { create(:master_variant) }
      let!(:past_price) { create(:price, variant: variant, valid_from: 1.year.ago) }
      let!(:current_price) { create(:price, variant: variant, valid_from: 1.week.ago) }
      let!(:future_price) { create(:price, variant: variant, valid_from: 1.week.from_now) }

      subject { described_class.valid_before(1.second.ago) }

      it { is_expected.to contain_exactly(past_price, current_price) }
    end
    describe '.latest_valid_from_first' do
      let(:variant) { create(:master_variant) }
      let!(:past_price) { create(:price, variant: variant, valid_from: 1.year.ago) }
      let!(:current_price) { create(:price, variant: variant, valid_from: 1.week.ago) }
      let!(:future_price) { create(:price, variant: variant, valid_from: 1.week.from_now) }

      subject { described_class.latest_valid_from_first.first }

      it { is_expected.to eq(future_price) }
    end

    describe '.valid_before_now' do
      subject { described_class.valid_before_now }

      it 'calls valid_before with the current time' do
        Timecop.freeze do
          expect(described_class).to receive(:valid_before).with(Time.current)
          subject
        end
      end
    end
  end

  describe 'initialization' do
    let(:variant) { create(:variant) }
    subject { described_class.new(variant: variant, valid_from: valid_from) }

    context 'with a valid from date given' do
      let(:valid_from) { "1990-01-01" }

      it 'stays the same' do
        subject.save
        expect(subject.valid_from).to eq(Date.new(1990, 01, 01))
      end
    end

    context 'with no valid from date given' do
      let(:valid_from) { nil }
      let(:now) { Time.current }

      it 'gets filled up with the current time' do
        Timecop.freeze(now) { subject.save }
        expect(subject.valid_from).to eq(now)
      end
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
  end
end
