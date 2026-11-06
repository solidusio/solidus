# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order do
  subject { described_class.new }
  it { is_expected.to respond_to(:order_promotions) }
  it { is_expected.to respond_to(:promotions) }

  describe ".ransackable_associations" do
    subject { described_class.ransackable_associations }

    it { is_expected.to include("promotions", "order_promotions") }
  end

  context "#apply_shipping_promotions" do
    let(:order) { build(:order) }

    it "calls out to the Shipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::Shipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.recalculator).to receive(:recalculate).and_call_original

      order.apply_shipping_promotions
    end

    context "after the order state machine is reloaded" do
      let(:order) { create(:order_with_line_items, state: :delivery) }

      before do
        @old_checkout_flow = Spree::Order.checkout_flow
        Spree::Order.checkout_flow(&@old_checkout_flow)
      end

      it "calls apply_shipping_promotions " do
        expect(order).to receive(:apply_shipping_promotions)
        order.next!
      end
    end
  end

  context "empty!" do
    let!(:order) { create(:order) }
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end
    let(:code) { promotion.codes.first }

    before do
      create(:line_item, order:)
      create(:shipment, order:)
      create(:adjustment, adjustable: order, order:)
      promotion.activate(order:, promotion_code: code)
      order.recalculate

      # Make sure we are asserting changes
      expect(order.line_items).not_to be_empty
      expect(order.shipments).not_to be_empty
      expect(order.adjustments).not_to be_empty
      expect(order.promotions).not_to be_empty
      expect(order.item_total).not_to eq 0
      expect(order.item_count).not_to eq 0
      expect(order.shipment_total).not_to eq 0
      expect(order.adjustment_total).not_to eq 0
    end

    it "clears out line items, adjustments and update totals" do
      order.empty!
      expect(order.line_items).to be_empty
      expect(order.shipments).to be_empty
      expect(order.adjustments).to be_empty
      expect(order.promotions).to be_empty
      expect(order.item_total).to eq 0
      expect(order.item_count).to eq 0
      expect(order.shipment_total).to eq 0
      expect(order.adjustment_total).to eq 0
    end
  end

  describe "order deletion" do
    let(:order) { create(:order) }
    let(:promotion) { create(:promotion) }

    subject { order.destroy }
    before do
      order.promotions << promotion
    end

    it "deletes join table entries when deleting an order" do
      expect { subject }.to change { Spree::OrderPromotion.count }.from(1).to(0)
    end
  end

  describe "#can_add_coupon?" do
    let(:order) { Spree::Order.new(state:) }

    subject { order.can_add_coupon? }

    context "when the order is in the cart state" do
      let(:state) { "cart" }

      it { is_expected.to eq(true) }
    end

    context "when the order is completed" do
      let(:state) { "complete" }

      it { is_expected.to eq(false) }
    end

    context "when the order is returned" do
      let(:state) { "returned" }

      it { is_expected.to eq(false) }
    end

    context "when the order is awaiting returns" do
      let(:state) { "returned" }

      it { is_expected.to eq(false) }
    end
  end

  describe "completing with usage limited promotions" do
    let!(:promotion) do
      create(:promotion, :with_order_adjustment, code: "limited", usage_limit: 1, per_code_usage_limit: 1)
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

        expect(order.errors[:base]).to include(I18n.t("spree.promotion_usage_limit_reached_before_complete"))
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
