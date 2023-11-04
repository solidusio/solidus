# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::LineItem do
  it { is_expected.to belong_to(:managed_by_order_action).optional }

  describe "#discountable_amount" do
    let(:discounts) { [] }
    let(:line_item) { Spree::LineItem.new(price: 10, quantity: 2, current_discounts: discounts) }

    subject(:discountable_amount) { line_item.discountable_amount }

    it { is_expected.to eq(20) }

    context "with a proposed discount" do
      let(:discounts) do
        [
          SolidusFriendlyPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
        ]
      end

      it { is_expected.to eq(18) }
    end
  end

  describe "#reset_current_discounts" do
    let(:line_item) { Spree::LineItem.new }

    subject { line_item.reset_current_discounts }
    before do
      line_item.current_discounts << SolidusFriendlyPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
    end

    it "resets the current discounts to an empty array" do
      expect { subject }.to change { line_item.current_discounts.length }.from(1).to(0)
    end
  end
end
