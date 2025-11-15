# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::ShippingRate do
  let(:subject) { build(:shipping_rate) }

  describe "#display_price" do
    before { subject.amount = 5 }

    it "returns formatted amount" do
      expect(subject.display_price).to eq("$5.00")
    end
  end

  describe "#total_before_tax" do
    subject { shipping_rate.total_before_tax }

    let(:shipping_rate) { build(:shipping_rate, cost: 4) }

    it { is_expected.to eq(4) }

    context "with discounts" do
      let(:shipping_rate) { build(:shipping_rate, cost: 4, discounts: discounts) }
      let(:discounts) { build_list(:solidus_shipping_rate_discount, 2, amount: -1.5, label: "DISCOUNT") }

      it { is_expected.to eq(1) }
    end
  end

  describe "#display_total_before_tax" do
    subject { shipping_rate.display_total_before_tax }

    let(:shipping_rate) { build(:shipping_rate, cost: 10) }

    it { is_expected.to eq(Spree::Money.new("10.00")) }
  end

  describe "#display_promo_total" do
    subject { shipping_rate.display_promo_total }

    let(:shipping_rate) { build(:shipping_rate) }

    it { is_expected.to eq(Spree::Money.new("0")) }
  end

  describe "#discountable_amount" do
    let(:discounts) { [] }
    let(:shipping_rate) { Spree::ShippingRate.new(amount: 20, current_discounts: discounts) }

    subject(:discountable_amount) { shipping_rate.discountable_amount }

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
    let(:shipping_rate) { Spree::ShippingRate.new }

    subject { shipping_rate.reset_current_discounts }
    before do
      shipping_rate.current_discounts << SolidusPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
    end

    it "resets the current discounts to an empty array" do
      expect { subject }.to change { shipping_rate.current_discounts.length }.from(1).to(0)
    end
  end

  describe "#previous_lane_discounts" do
    let(:order) { Spree::Order.new }
    let(:shipment) { Spree::Shipment.new(order:) }
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:shipping_rate) { Spree::ShippingRate.new(discounts:, shipment:) }
    let(:discounts) { [pre_lane_discount, post_lane_discount] }
    let(:pre_lane_discount) { SolidusPromotions::ShippingRateDiscount.new(benefit: pre_lane_promotion.benefits.first) }
    let(:post_lane_discount) { SolidusPromotions::ShippingRateDiscount.new(benefit: post_lane_promotion.benefits.first) }

    subject { shipping_rate.previous_lane_discounts }

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
      it { is_expected.to be_empty }

      context "if lane is default" do
        let(:lane) { "default" }

        it { is_expected.to contain_exactly(pre_lane_discount) }
      end

      context "if lane is post" do
        let(:lane) { "post" }

        it { is_expected.to contain_exactly(pre_lane_discount) }
      end
    end
  end

  describe "#current_lane_discounts" do
    let(:order) { Spree::Order.new }
    let(:shipment) { Spree::Shipment.new(order:) }
    let(:tax_rate) { create(:tax_rate) }
    let(:pre_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre) }
    let(:post_lane_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :post) }
    let(:shipping_rate) { Spree::ShippingRate.new(discounts:, shipment:) }
    let(:discounts) { [pre_lane_discount, post_lane_discount] }
    let(:pre_lane_discount) { SolidusPromotions::ShippingRateDiscount.new(benefit: pre_lane_promotion.benefits.first) }
    let(:post_lane_discount) { SolidusPromotions::ShippingRateDiscount.new(benefit: post_lane_promotion.benefits.first) }

    subject { shipping_rate.current_lane_discounts }

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
      it { is_expected.to contain_exactly(pre_lane_discount) }

      context "if lane is default" do
        let(:lane) { "default" }

        it { is_expected.to be_empty }
      end

      context "if lane is post" do
        let(:lane) { "post" }

        it { is_expected.to contain_exactly(post_lane_discount) }
      end
    end
  end
end
