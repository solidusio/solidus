# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order do
  subject { described_class.new }
  it { is_expected.to respond_to(:order_promotions) }
  it { is_expected.to respond_to(:promotions) }

  context "#apply_shipping_promotions" do
    let(:order) { build(:order) }

    it "calls out to the Shipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::Shipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.recalculator).to receive(:recalculate).and_call_original

      order.apply_shipping_promotions
    end

    context "after the order state machine is reloaded", :pending do
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
      create(:line_item, order: order)
      create(:shipment, order: order)
      create(:adjustment, adjustable: order, order: order)
      promotion.activate(order: order, promotion_code: code)
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
    let(:order) { Spree::Order.new(state: state) }

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
end
