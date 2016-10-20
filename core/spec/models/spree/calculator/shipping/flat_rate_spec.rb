require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe FlatRate, type: :model do
      subject { Calculator::Shipping::FlatRate.new(preferred_amount: 4.00) }

      describe ".description" do
        subject { described_class.description }
        it { is_expected.to eq("Flat rate") }
      end

      it 'always returns the same rate' do
        expect(subject.compute(build(:stock_package_fulfilled))).to eql 4.00
      end
    end
  end
end
