# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::FlatPercentItemTotal, type: :model do
  let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new }
  let(:line_item) { create(:line_item) }

  it_behaves_like 'a calculator with a description'

  before { allow(calculator).to receive_messages preferred_flat_percent: 10 }

  context "compute" do
    it "should round result correctly" do
      allow(line_item).to receive_messages amount: 31.08
      expect(calculator.compute(line_item)).to eq 3.11

      allow(line_item).to receive_messages amount: 31.00
      expect(calculator.compute(line_item)).to eq 3.10
    end

    it "should round result based on order currency" do
      line_item.order.currency = 'JPY'
      allow(line_item).to receive_messages amount: 31.08
      expect(calculator.compute(line_item)).to eq 3

      allow(line_item).to receive_messages amount: 31.00
      expect(calculator.compute(line_item)).to eq 3
    end

    it 'returns object.amount if computed amount is greater' do
      allow(calculator).to receive_messages preferred_flat_percent: 110
      allow(line_item).to receive_messages amount: 30.00

      expect(calculator.compute(line_item)).to eq 30.0
    end
  end
end
