require 'spec_helper'

describe Spree::PromotionBuilder do
  let(:promotion) { build(:promotion) }
  let(:base_code) { 'abc' }
  let(:number_of_codes) { 1 }
  let(:promotion_attrs) { { name: 'some promo' } }
  let(:builder) {
    Spree::PromotionBuilder.new(
      {
        base_code: base_code,
        number_of_codes: number_of_codes
      },
    promotion_attrs
  )
  }

  describe '#initialize' do
    subject { builder }
    it 'has the right base code' do
      expect(subject.base_code).to eq 'abc'
    end

    it 'has the right base code' do
      expect(subject.number_of_codes).to eq 1
    end
  end

  describe '#valid?' do
    subject { builder.valid? }

    it 'is true' do
      expect(subject).to be
    end

    context 'promotion is not valid' do
      let(:promotion_attrs) { { name: nil } }

      it 'is true' do
        expect(subject).to_not be
      end

      it 'has errors on the promotion' do
        subject
        expect(builder.errors).to_not be_empty
      end
    end

    context 'number of codes is invalid' do
      let(:number_of_codes) { -1 }

      it 'is false ' do
        expect(subject).to_not be
      end

      it 'validates numericality' do
        subject
        expect(builder.errors.full_messages).to eq ["Number of codes must be greater than 0"]
      end
    end
  end

  describe '#number_of_codes=' do
    it 'coerces a string' do
      builder.number_of_codes = '3'
      expect(builder.number_of_codes).to eq 3
    end

    it 'is nil for empty string' do
      builder.number_of_codes = ''
      expect(builder.number_of_codes).to be_nil
    end
  end

  describe "#perform" do
    subject { builder.perform }

    context 'when the builder is invalid' do
      let(:number_of_codes) { 'sups' }

      it 'returns false' do
        expect(subject).to_not be
      end
    end

    context "when the builder is valid" do
      context "when the builder cant build promotion codes" do
        let(:number_of_codes) { nil }

        it "doesn't create any new codes" do
          subject
          expect(builder.promotion.codes).to be_empty
        end
      end

      context "when the builder can build promotion codes" do
        let(:number_of_codes) { 1 }

        it "creates the correct number of codes" do
          subject
          expect(builder.promotion.codes.length).to eq number_of_codes
        end

        it "creates the promotion with the correct code" do
          subject
          expect(builder.promotion.codes.first.value).to eq base_code
        end
      end

      it "saves the promotion" do
        subject
        expect(builder.promotion).to be_persisted
      end

      it "returns true on success" do
        expect(subject).to be true
      end
    end
  end
end
