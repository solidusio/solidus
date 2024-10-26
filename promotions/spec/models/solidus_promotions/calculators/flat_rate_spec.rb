# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::FlatRate, type: :model do
  subject { calculator.compute(line_item) }

  let(:line_item) { mock_model(Spree::LineItem, order: order) }
  let(:order) { mock_model(Spree::Order, currency: order_currency) }
  let(:calculator) do
    described_class.new(
      preferred_amount: preferred_amount,
      preferred_currency: preferred_currency
    )
  end

  it_behaves_like "a calculator with a description"

  context "compute" do
    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end

    describe "when preferred currency does not match order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "USD" }
      let(:preferred_amount) { 25 }

      it { is_expected.to be_zero }
    end

    describe "when preferred currency does not match order" do
      let(:preferred_currency) { "" }
      let(:order_currency) { "USD" }
      let(:preferred_amount) { 25 }

      it { is_expected.to be_zero }
    end

    describe "when preferred currency and order currency use different casing" do
      let(:preferred_currency) { "gbP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end
end
