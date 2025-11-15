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

  describe "#discounts_by_lanes" do
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:line_item) { Spree::LineItem.new(adjustments:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { line_item.discounts_by_lanes(lanes) }

    context "if lanes is empty" do
      let(:lanes) { [] }
      it { is_expected.to be_empty }
    end

    context "if lanes is all lanes" do
      let(:lanes) { SolidusPromotions::Promotion.ordered_lanes }

      it { is_expected.to contain_exactly(pre_lane_adjustment, post_lane_adjustment) }
    end

    context "if lanes is only pre lane" do
      let(:lanes) { [:pre] }

      it { is_expected.to contain_exactly(pre_lane_adjustment) }
    end

    context "if lanes is only default lane" do
      let(:lanes) { [:default] }

      it { is_expected.to be_empty }
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

  describe "#previous_lane_discounts" do
    let(:order) { Spree::Order.new }
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:line_item) { Spree::LineItem.new(adjustments:, order:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { line_item.previous_lane_discounts }

    it "contains all adjustments if we're not calculating promotions" do
      expect(subject).to contain_exactly(pre_lane_adjustment, post_lane_adjustment)
    end

    context "while calculating promotions" do
      around do |example|
        SolidusPromotions::Promotion.within_lane(lane) do
          example.run
        end
      end

      let(:lane) { "pre" }
      it { is_expected.to be_empty }

      context "if lane is default" do
        let(:lane) { "default" }

        it { is_expected.to contain_exactly(pre_lane_adjustment) }
      end

      context "if lane is post" do
        let(:lane) { "post" }

        it { is_expected.to contain_exactly(pre_lane_adjustment) }
      end
    end
  end

  describe "#current_lane_discounts" do
    let(:order) { Spree::Order.new }
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:line_item) { Spree::LineItem.new(adjustments:, order:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { line_item.current_lane_discounts }

    it "raises unless we're doing a promotion calculation" do
      expect { subject }.to raise_exception(SolidusPromotions::NotCalculatingPromotions)
    end

    context "while calculating promotions" do
      around do |example|
        SolidusPromotions::Promotion.within_lane(lane) do
          example.run
        end
      end

      let(:lane) { "pre" }
      it { is_expected.to contain_exactly(pre_lane_adjustment) }

      context "if lane is default" do
        let(:lane) { "default" }

        it { is_expected.to be_empty }
      end

      context "if lane is post" do
        let(:lane) { "post" }

        it { is_expected.to contain_exactly(post_lane_adjustment) }
      end
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
end
