require 'spec_helper'

describe Spree::Calculator::TieredPercent, type: :model do
  let(:calculator) { Spree::Calculator::TieredPercent.new }

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
      context "and one of the keys is not a positive number" do
        before { calculator.preferred_tiers = { "nope" => 20 } }
        it { is_expected.to be false }
      end
      context "and one of the values is not a percent" do
        before { calculator.preferred_tiers = { 10 => 110 } }
        it { is_expected.to be false }
      end
    end
  end

  describe "#compute" do
    let(:order) { create(:order_with_line_items, line_items_count: line_item_count, line_items_price: price) }
    let(:price) { 10 }

    before do
      calculator.preferred_base_percent = 10
      calculator.preferred_tiers = {
        20 => 15,
        30 => 20
      }
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
    end
  end
end
