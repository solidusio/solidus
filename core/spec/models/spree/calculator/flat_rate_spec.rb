# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/calculator"

RSpec.describe Spree::Calculator::FlatRate, type: :model do
  let(:calculator) { Spree::Calculator::FlatRate.new }

  it_behaves_like "a calculator with a description"

  let(:order) do
    mock_model(
      Spree::Order, quantity: 10, currency: "USD"
    )
  end

  context "compute" do
    it "should compute the amount as the rate when currency matches the order's currency" do
      calculator.preferred_amount = 25.0
      calculator.preferred_currency = "GBP"
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(25.0)
    end

    it "should compute the amount as 0 when currency does not match the order's currency" do
      calculator.preferred_amount = 100.0
      calculator.preferred_currency = "GBP"
      allow(order).to receive_messages currency: "USD"
      expect(calculator.compute(order).round(2)).to eq(0.0)
    end

    it "should compute the amount as 0 when currency is blank" do
      calculator.preferred_amount = 100.0
      calculator.preferred_currency = ""
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(0.0)
    end

    it "should compute the amount as the rate when the currencies use different casing" do
      calculator.preferred_amount = 100.0
      calculator.preferred_currency = "gBp"
      allow(order).to receive_messages currency: "GBP"
      expect(calculator.compute(order).round(2)).to eq(100.0)
    end

    it "should compute the amount as 0 when there is no object" do
      calculator.preferred_amount = 100.0
      calculator.preferred_currency = "GBP"
      expect(calculator.compute.round(2)).to eq(0.0)
    end
  end
end
