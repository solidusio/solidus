# frozen_string_literal: true

require "spec_helper"

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
      let(:discounts) { build_list(:friendly_shipping_rate_discount, 2, amount: -1.5, label: "DISCOUNT") }

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
end
