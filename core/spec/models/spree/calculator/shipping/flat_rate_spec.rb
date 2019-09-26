# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  module Calculator::Shipping
    RSpec.describe FlatRate, type: :model do
      subject { described_class.new(preferred_amount: 4.00) }

      it_behaves_like 'a calculator with a description'

      it 'always returns the same rate' do
        expect(subject.compute(build(:stock_package_fulfilled))).to eql 4.00
      end
    end
  end
end
