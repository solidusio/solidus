# frozen_string_literal: true

require "spec_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusFriendlyPromotions::Calculators::TieredFlatRate, type: :model do
  let(:calculator) { described_class.new }

  it_behaves_like "a calculator with a description"

  describe "#valid?" do
    subject { calculator.valid? }

    context "when tiers is a hash" do
      context "and the key is not a positive number" do
        before { calculator.preferred_tiers = {"nope" => 20} }

        it { is_expected.to be false }
      end

      context "and the key is an integer" do
        before { calculator.preferred_tiers = {20 => 20} }

        it "converts successfully" do
          expect(subject).to be true
          expect(calculator.preferred_tiers).to eq({BigDecimal("20") => BigDecimal("20")})
        end
      end

      context "and the key is a float" do
        before { calculator.preferred_tiers = {20.5 => 20.5} }

        it "converts successfully" do
          expect(subject).to be true
          expect(calculator.preferred_tiers).to eq({BigDecimal("20.5") => BigDecimal("20.5")})
        end
      end

      context "and the key is a string number" do
        before { calculator.preferred_tiers = {"20" => 20} }

        it "converts successfully" do
          expect(subject).to be true
          expect(calculator.preferred_tiers).to eq({BigDecimal("20") => BigDecimal("20")})
        end
      end

      context "and the key is a numeric string with spaces" do
        before { calculator.preferred_tiers = {"  20 " => 20} }

        it "converts successfully" do
          expect(subject).to be true
          expect(calculator.preferred_tiers).to eq({BigDecimal("20") => BigDecimal("20")})
        end
      end

      context "and the key is a string number with decimals" do
        before { calculator.preferred_tiers = {"20.5" => "20.5"} }

        it "converts successfully" do
          expect(subject).to be true
          expect(calculator.preferred_tiers).to eq({BigDecimal("20.5") => BigDecimal("20.5")})
        end
      end
    end
  end

  describe "#compute" do
    subject { calculator.compute(line_item) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: 1,
        line_items_price: amount
      )
    end
    let(:line_item) { order.line_items.first }
    let(:preferred_currency) { "USD" }

    before do
      calculator.preferred_base_amount = 10
      calculator.preferred_tiers = {
        100 => 15,
        200 => 20
      }
      calculator.preferred_currency = preferred_currency
    end

    context "when amount falls within the first tier" do
      let(:amount) { 50 }

      it { is_expected.to eq 10 }
    end

    context "when amount falls within the second tier" do
      let(:amount) { 150 }

      it { is_expected.to eq 15 }
    end

    context "when the order's currency does not match the calculator" do
      let(:preferred_currency) { "CAD" }
      let(:amount) { 50 }

      it { is_expected.to eq 0 }
    end

    context "with a shipment" do
      subject { calculator.compute(shipment) }

      let(:shipment) { Spree::Shipment.new(order: order, amount: shipping_cost) }
      let(:line_item_count) { 1 }
      let(:amount) { 10 }

      context "for multiple line items" do
        context "when amount falls within the first tier" do
          let(:shipping_cost) { 110 }

          it { is_expected.to eq 15 }
        end

        context "when amount falls within the second tier" do
          let(:shipping_cost) { 210 }

          it { is_expected.to eq 20 }
        end

        context "when the order's currency does not match the calculator" do
          let(:preferred_currency) { "CAD" }
          let(:shipping_cost) { 110 }

          it { is_expected.to eq 0 }
        end
      end
    end
  end
end
