# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Shipment do
  describe "#discountable_amount" do
    let(:discounts) { [] }
    let(:shipment) { Spree::Shipment.new(amount: 20, current_discounts: discounts) }

    subject(:discountable_amount) { shipment.discountable_amount }

    it { is_expected.to eq(20) }

    context "with a proposed discount" do
      let(:discounts) do
        [
          SolidusPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
        ]
      end

      it { is_expected.to eq(18) }
    end

    describe "#reset_current_discounts" do
      let(:shipping_rate) { Spree::ShippingRate.new }
      let(:shipment) { Spree::Shipment.new(shipping_rates: [shipping_rate]) }

      subject { shipment.reset_current_discounts }
      before do
        shipment.current_discounts << SolidusPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
      end

      it "resets the current discounts to an empty array and resets current discounts on all shipping rates" do
        expect(shipping_rate).to receive(:reset_current_discounts)
        expect { subject }.to change { shipment.current_discounts.length }.from(1).to(0)
      end
    end
  end

  describe "#discounts_by_lanes" do
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:shipment) { Spree::Shipment.new(adjustments:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { shipment.discounts_by_lanes(lanes) }

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

  describe "#previous_lane_discounts" do
    let(:order) { Spree::Order.new }
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:shipment) { Spree::Shipment.new(adjustments:, order:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { shipment.previous_lane_discounts }

    it "returns all adjustment when not calculating promotions" do
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
    let(:shipment) { Spree::Shipment.new(adjustments:, order:) }
    let(:adjustments) { [tax_adjustment, pre_lane_adjustment, post_lane_adjustment] }
    let(:tax_adjustment) { Spree::Adjustment.new(source: tax_rate, amount: 2) }
    let(:pre_lane_adjustment) { Spree::Adjustment.new(source: pre_lane_promotion.benefits.first) }
    let(:post_lane_adjustment) { Spree::Adjustment.new(source: post_lane_promotion.benefits.first) }

    subject { shipment.current_lane_discounts }

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
end
