# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  module Calculator::Shipping
    RSpec.describe PerItem, type: :model do
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }

      it_behaves_like 'a calculator with a description'

      let(:package) do
        build(:stock_package, variants_contents: { variant1 => 5, variant2 => 3 })
      end

      subject { described_class.new(preferred_amount: 10) }

      it "correctly calculates per item shipping" do
        expect(subject.compute(package).to_f).to eq(80) # 5 x 10 + 3 x 10
      end
    end
  end
end
