# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe ShippingRateTax, type: :model do
    subject(:shipping_rate_tax) { described_class.new }

    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:tax_rate) }
    it { is_expected.to respond_to(:shipping_rate) }

    describe 'absolute_amount' do
      subject(:shipping_rate_tax) { described_class.new(amount: amount).absolute_amount }

      context 'with a negative amount' do
        let(:amount) { -19 }

        it { is_expected.to eq(19) }
      end

      context 'with a positive amount' do
        let(:amount) { 19 }
        it { is_expected.to eq(19) }
      end
    end

    describe 'display_absolute_amount' do
      subject(:shipping_rate_tax) { described_class.new(amount: 10).display_absolute_amount.to_s }

      it { is_expected.to eq("$10.00") }
    end

    describe '#currency' do
      subject(:shipping_rate_tax) { described_class.new(amount: 10, shipping_rate: shipping_rate).currency }

      context 'when we have a shipping rate' do
        let(:shipping_rate) { build_stubbed(:shipping_rate) }

        it 'delegates the call to the shipment' do
          expect(shipping_rate).to receive(:currency)
          subject
        end
      end

      context "when we don't have a shipping rate" do
        let(:shipping_rate) { nil }

        it 'is nil' do
          expect(subject).to eq(nil)
        end
      end
    end

    describe '#label' do
      subject(:shipping_rate_tax) { described_class.new(amount: amount, tax_rate: tax_rate).label }

      context 'with an included tax rate' do
        let(:tax_rate) { build_stubbed(:tax_rate, included_in_price: true, name: "VAT") }

        context 'with a positive amount' do
          let(:amount) { 2.2 }
          it 'labels an included tax' do
            expect(subject).to eq("incl. $2.20 VAT")
          end
        end
      end

      context 'with an additional tax rate' do
        let(:tax_rate) { build_stubbed(:tax_rate, included_in_price: false, name: "Sales Tax") }
        let(:amount) { 2.2 }

        it 'labels an additional tax' do
          expect(subject).to eq("+ $2.20 Sales Tax")
        end
      end
    end
  end
end
