# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::OrderContents, type: :model do
  let!(:store) { create :store }
  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let!(:stock_location) { variant.stock_locations.first }
  let(:stock_location_2) { create(:stock_location) }

  subject(:order_contents) { described_class.new(order) }

  context "#add" do
    context "running promotions" do
      let(:promotion) { create(:promotion, apply_automatically: true) }
      let(:calculator) { Spree::Calculator::FlatRate.new(preferred_amount: 10) }

      shared_context "discount changes order total" do
        before { subject.add(variant, 1) }
        it { expect(subject.order.total).not_to eq variant.price }
      end

      context "one active order promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateAdjustment.create(promotion:, calculator:) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end

      context "one active line item promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(promotion:, calculator:) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end
    end
  end

  context "update cart" do
    let!(:shirt) { subject.add variant, 1 }

    let(:params) do
      {line_items_attributes: {
        "0" => {id: shirt.id, quantity: 3}
      }}
    end

    it "changes item quantity" do
      subject.update_cart params
      expect(shirt.reload.quantity).to eq 3
    end

    it "updates order totals" do
      expect {
        subject.update_cart params
      }.to change { subject.order.total }
    end

    context "submits item quantity 0" do
      let(:params) do
        {line_items_attributes: {
          "0" => {id: shirt.id, quantity: 0}
        }}
      end

      it "removes item from order" do
        expect {
          subject.update_cart params
        }.to change { subject.order.line_items.count }
      end
    end

    it "ensures updated shipments" do
      expect(subject.order).to receive(:check_shipments_and_restart_checkout)
      subject.update_cart params
    end
  end

  context "completed order" do
    let(:order) do
      Spree::Order.create!(
        state: "complete",
        completed_at: Time.current,
        email: "test@example.com"
      )
    end

    before { order.shipments.create! stock_location_id: variant.stock_location_ids.first }

    it "updates order payment state" do
      expect {
        subject.add variant
      }.to change { order.payment_state }

      expect {
        subject.remove variant
      }.to change { order.payment_state }
    end
  end
end
