# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order do
  it { is_expected.to have_many :solidus_promotions }
  it { is_expected.to have_many :solidus_order_promotions }

  describe "#reset_current_discounts" do
    let(:line_item) { Spree::LineItem.new }
    let(:shipment) { Spree::Shipment.new }
    let(:order) { Spree::Order.new(shipments: [shipment], line_items: [line_item]) }

    subject { order.reset_current_discounts }

    it "resets the current discounts on all line items and shipments" do
      expect(line_item).to receive(:reset_current_discounts)
      expect(shipment).to receive(:reset_current_discounts)
      subject
    end
  end

  describe "order deletion" do
    let(:order) { create(:order) }
    let(:promotion) { create(:solidus_promotion) }

    subject { order.destroy }
    before do
      order.solidus_promotions << promotion
    end

    it "deletes join table entries when deleting an order" do
      expect { subject }.to change { SolidusPromotions::OrderPromotion.count }.from(1).to(0)
    end
  end

  describe ".allowed_ransackable_associations" do
    subject { described_class.allowed_ransackable_associations }

    it { is_expected.to include("solidus_promotions", "solidus_order_promotions") }
  end

  describe "#coupon_code=" do
    let(:order) { create(:order) }
    let(:promotion) { create(:promotion, code: "10off") }
    let(:coupon_code) { "10OFF" }

    subject { order.coupon_code = coupon_code }

    context "when coupon code is case-insensitive (default)" do
      it "converts coupon codes to lowercase" do
        subject
        expect(order.coupon_code).to eq("10off")
      end
    end

    context "when coupon code is case-sensitive" do
      before do
        stub_const("CaseSensitiveNormalizer", Class.new do
          def self.call(value)
            value&.strip
          end
        end)

        stub_spree_preferences(
          SolidusPromotions.configuration,
          coupon_code_normalizer_class: CaseSensitiveNormalizer
        )
      end

      it "preserves case in coupon codes" do
        subject
        expect(order.coupon_code).to eq("10OFF")
      end
    end
  end
end
