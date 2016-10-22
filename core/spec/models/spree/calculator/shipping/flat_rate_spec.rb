require 'spec_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  module Calculator::Shipping
    describe FlatRate, type: :model do
      subject { Calculator::Shipping::FlatRate.new(preferred_amount: 4.00) }

      it_behaves_like 'a calculator with a description'

      it 'always returns the same rate' do
        expect(subject.compute(build(:stock_package_fulfilled))).to eql 4.00
      end
    end
  end
end
