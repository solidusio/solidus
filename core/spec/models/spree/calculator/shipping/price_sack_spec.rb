# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::Shipping::PriceSack, type: :model do
  let(:calculator) do
    calculator = described_class.new
    calculator.preferred_minimal_amount = 5
    calculator.preferred_normal_amount = 10
    calculator.preferred_discount_amount = 1
    calculator
  end

  it_behaves_like 'a calculator with a description'

  describe '#compute' do
    subject { calculator.compute(package) }
    let(:package) { build(:stock_package, variants_contents: { build(:variant) => 1 }) }

    before do
      # This hack is due to our factories not being so smart to understand
      # that they should create line items with the price of the associated
      # variant by default.
      allow_any_instance_of(Spree::Stock::ContentItem).to receive(:price) { amount }
    end

    context 'when price < minimal amount' do
      let(:amount) { 2 }

      it "returns the discounted amount" do
        expect(subject).to eq(10)
      end
    end

    context 'when price > minimal amount' do
      let(:amount) { 6 }

      it "returns the discounted amount" do
        expect(subject).to eq(1)
      end
    end
  end
end
