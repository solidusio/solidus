# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::OrderContents, type: :model do
  let!(:store) { create :store }
  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let!(:stock_location) { variant.stock_locations.first }
  let(:stock_location_2) { create(:stock_location) }

  subject(:order_contents) { described_class.new(order) }

  describe "recalculation count when no promotion applies" do
    shared_examples "a single recalculation" do
      it "recalculates the order once" do
        allow(order).to receive(:recalculate).and_call_original

        change_cart

        expect(order).to have_received(:recalculate).once
      end
    end

    context "when an item is added" do
      def change_cart
        order_contents.add(variant, 1)
      end

      it_behaves_like "a single recalculation"
    end

    context "when a quantity is updated" do
      before { order_contents.add(variant, 1) }

      def change_cart
        order_contents.update_cart(line_items_attributes: {"0" => {id: order.line_items.first.id, quantity: 3}})
      end

      it_behaves_like "a single recalculation"
    end

    context "when an item is removed" do
      before { order_contents.add(variant, 1) }

      def change_cart
        order_contents.remove_line_item(order.line_items.first)
      end

      it_behaves_like "a single recalculation"
    end
  end

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

    context "with an automatic ItemTotal promotion the update makes eligible" do
      let!(:promotion) { create(:promotion, apply_automatically: true) }
      let!(:action) do
        Spree::Promotion::Actions::CreateAdjustment.create(
          promotion:, calculator: Spree::Calculator::FlatRate.new(preferred_amount: 5)
        )
      end
      let!(:rule) do
        Spree::Promotion::Rules::ItemTotal.create(
          preferred_operator: "gt", preferred_amount: variant.price * 2, promotion:
        )
      end

      it "does not apply while the item total is below the threshold" do
        expect(order.adjustments).to be_empty
      end

      it "applies once the raised quantity crosses the threshold" do
        order_contents.update_cart(params)
        expect(order.adjustments.reload.map(&:source)).to include(action)
      end
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

  describe "persisted totals after a cart change" do
    let(:order) { create(:order_with_line_items, line_items_count: 1, state: "delivery") }
    let(:total_columns) do
      %w[item_total adjustment_total included_tax_total additional_tax_total
        promo_total shipment_total payment_total total item_count]
    end

    shared_examples "totals a further recalculation would not change" do
      it "persists the same totals a full recalculation would" do
        change_cart

        expect { order.recalculate }
          .not_to change { order.reload.attributes.slice(*total_columns) }
      end
    end

    context "when an item is added" do
      def change_cart
        order_contents.add(create(:variant), 1)
      end

      it_behaves_like "totals a further recalculation would not change"
    end

    context "when a quantity is updated" do
      def change_cart
        order_contents.update_cart(line_items_attributes: {"0" => {id: order.line_items.first.id, quantity: 3}})
      end

      it_behaves_like "totals a further recalculation would not change"
    end

    context "when an item is removed" do
      def change_cart
        order_contents.remove_line_item(order.line_items.first)
      end

      it_behaves_like "totals a further recalculation would not change"
    end

    # A cart change on an order past the cart step destroys its pending shipments and
    # zeroes shipment_total with update_column, which does not touch total. The order
    # is only recalculated once, so that recalculation has to happen after the
    # shipments are gone or the destroyed shipment's cost stays stranded in total.
    context "when the change destroys the order's pending shipments" do
      it "leaves the destroyed shipment's cost out of the persisted total" do
        expect(order.shipments).to be_present
        expect(order.shipment_total).to be > 0

        order_contents.update_cart(line_items_attributes: {"0" => {id: order.line_items.first.id, quantity: 3}})
        order.reload

        expect(order.shipments).to be_empty
        expect(order.shipment_total).to eq(0)
        expect(order.total).to eq(order.item_total + order.adjustment_total)
      end
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
