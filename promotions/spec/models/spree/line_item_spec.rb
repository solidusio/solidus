# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::LineItem do
  it { is_expected.to belong_to(:managed_by_order_benefit).optional }

  describe "#discountable_amount" do
    let(:discounts) { [] }
    let(:line_item) { Spree::LineItem.new(price: 10, quantity: 2, current_discounts: discounts) }

    subject(:discountable_amount) { line_item.discountable_amount }

    it { is_expected.to eq(20) }

    context "with a proposed discount" do
      let(:discounts) do
        [
          SolidusPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
        ]
      end

      it { is_expected.to eq(18) }
    end
  end

  describe "#reset_current_discounts" do
    let(:line_item) { Spree::LineItem.new }

    subject { line_item.reset_current_discounts }
    before do
      line_item.current_discounts << SolidusPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
    end

    it "resets the current discounts to an empty array" do
      expect { subject }.to change { line_item.current_discounts.length }.from(1).to(0)
    end
  end

  describe "changing quantities" do
    context "when line item is managed by an automation" do
      let(:order) { create(:order) }
      let(:variant) { create(:variant) }
      let(:promotion) { create(:solidus_promotion, apply_automatically: true) }
      let(:promotion_benefit) { SolidusPromotions::Benefits::CreateDiscountedItem.create!(calculator: hundred_percent, preferred_variant_id: variant.id, promotion: promotion) }
      let(:hundred_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 100) }

      before do
        order.line_items.create!(variant: variant, managed_by_order_benefit: promotion_benefit, quantity: 1)
      end

      it "makes the line item invalid" do
        line_item = order.line_items.first
        line_item.quantity = 2
        expect { line_item.save! }.to raise_exception(ActiveRecord::RecordInvalid)
        expect(line_item.errors.full_messages.first).to eq("Quantity cannot be changed on a line item managed by a promotion benefit")
      end
    end
  end

  describe "adjusted_amount_by_lanes" do
    let(:line_item) { described_class.new(price: 12, quantity: 4, adjustments: adjustments) }
    let(:pre_adjustment) { Spree::Adjustment.new(amount: -1, source: pre_benefit) }
    let(:default_adjustment) { Spree::Adjustment.new(amount: -2, source: default_benefit) }
    let(:post_adjustment) { Spree::Adjustment.new(amount: -3, source: post_benefit) }
    let(:pre_promotion) { SolidusPromotions::Promotion.new(lane: :pre) }
    let(:default_promotion) { SolidusPromotions::Promotion.new(lane: :default) }
    let(:post_promotion) { SolidusPromotions::Promotion.new(lane: :post) }
    let(:pre_benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(promotion: pre_promotion) }
    let(:default_benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(promotion: default_promotion) }
    let(:post_benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(promotion: post_promotion) }
    let(:adjustments) { [pre_adjustment, default_adjustment, post_adjustment] }

    let(:lanes) { [] }

    subject { line_item.adjusted_amount_by_lanes(lanes) }
    it { is_expected.to eq(48) }

    context "if given pre lane" do
      let(:lanes) { ["pre"] }

      it { is_expected.to eq(47) }
    end

    context "if given default and pre lane" do
      let(:lanes) { ["pre", "default"] }
      it { is_expected.to eq(45) }
    end

    context "if given default, pre and post lane" do
      let(:lanes) { ["pre", "default", "post"] }
      it { is_expected.to eq(42) }
    end
  end
end
