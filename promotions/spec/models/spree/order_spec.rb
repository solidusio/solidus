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

  describe "completing with usage limited promotions" do
    let!(:promotion) do
      create(:solidus_promotion, :with_order_adjustment, code: "limited", usage_limit: 1, per_code_usage_limit: 1)
    end
    let(:code) { promotion.codes.first }
    let(:order) { create(:order_ready_to_complete) }

    before do
      order.coupon_code = "limited"
      Spree::Config.promotions.coupon_code_handler_class.new(order).apply
      order.payments.first.update!(amount: order.total)
    end

    it "claims a use of the promotion and its code" do
      order.complete!

      expect(order).to be_complete
      expect(promotion.reload.usage_claims_count).to eq(1)
      expect(code.reload.usage_claims_count).to eq(1)
    end

    context "when another checkout holds the last use of the code" do
      before { code.claim_usage }

      it "doesn't take payment and releases the use already claimed" do
        expect(order.complete).to be(false)

        expect(order.errors[:base]).to include(I18n.t("solidus_promotions.usage_limit_reached_before_complete"))
        expect(order.payments.first.reload).to be_checkout
        expect(promotion.reload.usage_claims_count).to eq(0)
        expect(code.reload.usage_claims_count).to eq(1)
      end
    end

    context "when payment fails" do
      before do
        order.payments.destroy_all
        create(:payment, order:, amount: order.total, source: create(:credit_card, :failing))
        order.payments.reload
      end

      it "releases the claimed uses" do
        expect(order.complete).to be(false)

        expect(order.reload.state).to eq("payment")
        expect(promotion.reload.usage_claims_count).to eq(0)
        expect(code.reload.usage_claims_count).to eq(0)
      end
    end

    context "when payments are captured during completion" do
      before { stub_spree_preferences(auto_capture: true) }

      it "keeps the promotion it claimed the last use of" do
        expect { order.complete! }.not_to change { order.reload.promo_total }

        expect(order.promo_total).to be_negative
        expect(order.payment_state).to eq("paid")
      end
    end

    context "when payment processing raises an error" do
      before { allow(order).to receive(:process_payments!).and_raise(Timeout::Error) }

      it "releases the claimed uses" do
        expect { order.complete }.to raise_error(Timeout::Error)

        expect(promotion.reload.usage_claims_count).to eq(0)
        expect(code.reload.usage_claims_count).to eq(0)
      end
    end

    it "releases the uses when the order is canceled and claims them again when it is resumed" do
      order.complete!

      order.cancel!
      expect(promotion.reload.usage_claims_count).to eq(0)
      expect(code.reload.usage_claims_count).to eq(0)

      order.resume!
      expect(promotion.reload.usage_claims_count).to eq(1)
      expect(code.reload.usage_claims_count).to eq(1)
    end
  end
end
