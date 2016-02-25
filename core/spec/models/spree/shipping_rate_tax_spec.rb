require 'spec_helper'

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
  end
end
