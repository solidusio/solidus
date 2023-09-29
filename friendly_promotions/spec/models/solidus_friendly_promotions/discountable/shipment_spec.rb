# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Discountable::Shipment do
  let(:discountable_order) { double(SolidusFriendlyPromotions::Discountable::Order) }

  let(:spree_shipment) { build(:shipment, amount: 20) }

  subject(:discountable_shipment) { described_class.new(spree_shipment, order: discountable_order) }

  describe "#order" do
    subject { discountable_shipment.order }

    it { is_expected.to eq(discountable_order) }
  end

  describe "#discounted_amount" do
    subject(:discounted_amount) { discountable_shipment.discounted_amount }

    context "with no discounts" do
      it { is_expected.to eq(20) }
    end

    context "with discounts" do
      let(:discount) { SolidusFriendlyPromotions::ItemDiscount.new(amount: -4) }

      before do
        discountable_shipment.discounts << discount
      end

      it { is_expected.to eq(16) }
    end
  end

  describe "#shipping_rates" do
    subject(:shipping_rates) { discountable_shipment.shipping_rates }

    specify "are converted into Discountable Shipments" do
      shipping_rates.each do |shipping_rate|
        expect(shipping_rate).to be_a(SolidusFriendlyPromotions::Discountable::ShippingRate)
      end
    end
  end
end
