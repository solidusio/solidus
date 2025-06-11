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

  describe "adjusted_amount_by_lanes" do
    let(:shipment) { described_class.new(cost: 48, adjustments: adjustments) }
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

    subject { shipment.adjusted_amount_by_lanes(lanes) }
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
