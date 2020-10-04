# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::TieredPercent, type: :model do
  let(:calculator) { Spree::Calculator::TieredPercent.new }

  it_behaves_like 'a calculator with a description'

  describe "#valid?" do
    subject { calculator.valid? }

    context "when base percent is less than zero" do
      before { calculator.preferred_base_percent = -1 }
      it { is_expected.to be false }
    end

    context "when base percent is greater than 100" do
      before { calculator.preferred_base_percent = 110 }
      it { is_expected.to be false }
    end

    context "when tiers is a hash" do
      context "and the key is not a positive number" do
        before { calculator.preferred_tiers = { "nope" => 20 } }
        it { is_expected.to be false }
      end

      context "and one of the values is not a percent" do
        before { calculator.preferred_tiers = { 10 => 110 } }
        it { is_expected.to be false }
      end

      context "and the key is an integer" do
        before { calculator.preferred_tiers = { 20 => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal('20') => BigDecimal('20') })
        end
      end

      context "and the key is a float" do
        before { calculator.preferred_tiers = { 20.5 => 20.5 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal('20.5') => BigDecimal('20.5') })
        end
      end

      context "and the key is a string number" do
        before { calculator.preferred_tiers = { "20" => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal('20') => BigDecimal('20') })
        end
      end

      context "and the key is a numeric string with spaces" do
        before { calculator.preferred_tiers = { "  20 " => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal('20') => BigDecimal('20') })
        end
      end

      context "and the key is a string number with decimals" do
        before { calculator.preferred_tiers = { "20.5" => "20.5" } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal('20.5') => BigDecimal('20.5') })
        end
      end
    end
  end

  describe "#compute" do
    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: line_item_count,
        line_items_price: price
      )
    end
    let(:price) { 10 }
    let(:preferred_currency) { "USD" }

    before do
      calculator.preferred_base_percent = 10
      calculator.preferred_tiers = {
        20 => 15,
        30 => 20
      }
      calculator.preferred_currency = preferred_currency
    end

    context "with a line item" do
      let(:line_item) { order.line_items.first }
      subject { calculator.compute(line_item) }

      context "for multiple line items" do
        context "when amount falls within the first tier" do
          let(:line_item_count) { 1 }
          it { is_expected.to eq 1.0 }
        end

        context "when amount falls within the second tier" do
          let(:line_item_count) { 2 }
          it { is_expected.to eq 1.5 }
        end

        context "when amount falls within the third tier" do
          let(:line_item_count) { 3 }
          it { is_expected.to eq 2.0 }
        end
      end

      context "for a single line item" do
        let(:line_item_count) { 1 }

        context "when amount falls within the first tier" do
          let(:price) { 10 }
          it { is_expected.to eq 1.0 }
        end

        context "when amount falls within the second tier" do
          let(:price) { 20 }
          it { is_expected.to eq 3.0 }
        end

        context "when amount falls within the third tier" do
          let(:price) { 30 }
          it { is_expected.to eq 6.0 }
        end
      end

      context "when the order's currency does not match the calculator" do
        let(:preferred_currency) { "JPY" }
        let(:line_item_count) { 1 }
        let(:price) { 15 }
        it { is_expected.to eq 0 }

        it "rounds based on currency" do
          allow(order).to receive_messages currency: "JPY"
          expect(subject).to eq(2)
        end
      end
    end

    context "with an order" do
      subject { calculator.compute(order) }

      let(:line_item_count) { 1 }

      context "for multiple line items" do
        context "when amount falls within the first tier" do
          let(:line_item_count) { 1 }
          it { is_expected.to eq 1.0 }
        end

        context "when amount falls within the second tier" do
          let(:line_item_count) { 2 }
          it { is_expected.to eq 3.0 }
        end

        context "when amount falls within the third tier" do
          let(:line_item_count) { 3 }
          it { is_expected.to eq 6.0 }
        end
      end

      context "for a single line item" do
        let(:line_item_count) { 1 }

        context "when amount falls within the first tier" do
          let(:price) { 10 }
          it { is_expected.to eq 1.0 }
        end

        context "when amount falls within the second tier" do
          let(:price) { 20 }
          it { is_expected.to eq 3.0 }
        end

        context "when amount falls within the third tier" do
          let(:price) { 30 }
          it { is_expected.to eq 6.0 }
        end
      end

      context "when the order's currency does not match the calculator" do
        let(:preferred_currency) { "CAD" }
        it { is_expected.to eq 0 }
      end
    end
  end
end
