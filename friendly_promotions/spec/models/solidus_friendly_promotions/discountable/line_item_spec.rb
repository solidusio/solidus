# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Discountable::LineItem do
  let(:discountable_order) { double(SolidusFriendlyPromotions::Discountable::Order) }
  let(:spree_line_item) { build(:line_item, price: 10, quantity: 2) }

  subject(:discountable_line_item) { described_class.new(spree_line_item, order: discountable_order) }

  describe "#order" do
    subject { discountable_line_item.order }

    it { is_expected.to eq(discountable_order) }
  end

  describe "#discounted_amount" do
    subject(:discounted_amount) { discountable_line_item.discounted_amount }

    context "with no discounts" do
      it { is_expected.to eq(20) }
    end

    context "with discounts" do
      let(:discount) { SolidusFriendlyPromotions::ItemDiscount.new(amount: -4) }

      before do
        discountable_line_item.discounts << discount
      end

      it { is_expected.to eq(16) }
    end
  end
end
