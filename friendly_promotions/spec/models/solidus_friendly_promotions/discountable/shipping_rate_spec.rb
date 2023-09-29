# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Discountable::ShippingRate do
  let(:discountable_shipment) { double(SolidusFriendlyPromotions::Discountable::Shipment) }

  let(:spree_shipping_rate) { build(:shipping_rate, amount: 20) }

  subject(:discountable_shipping_rate) { described_class.new(spree_shipping_rate, shipment: discountable_shipment) }

  describe "#shipment" do
    subject { discountable_shipping_rate.shipment }

    it { is_expected.to eq(discountable_shipment) }
  end

  describe "#discounted_amount" do
    subject(:discounted_amount) { discountable_shipping_rate.discounted_amount }

    context "with no discounts" do
      it { is_expected.to eq(20) }
    end

    context "with discounts" do
      let(:discount) { SolidusFriendlyPromotions::ItemDiscount.new(amount: -4) }

      before do
        discountable_shipping_rate.discounts << discount
      end

      it { is_expected.to eq(16) }
    end
  end
end
