# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/working_factory'
require "spree/testing_support/shared_examples/order_factory"

RSpec.describe 'order factory' do
  let(:factory_class) { Spree::Order }

  describe 'plain order' do
    let(:factory) { :order }

    it_behaves_like 'a working factory'

    shared_examples "it has the expected attributes" do
      it do
        aggregate_failures do
          expect(order.bill_address).to be_present
          expect(order.ship_address).to be_present
          expect(order.user).to be_present
          expect(order.email).to be_present
          expect(order.email).to eq(order.user.email)
          expect(order.state).to eq "cart"
          expect(order.store).to be_present
          expect(order).not_to be_completed
        end
      end
    end

    context "when built" do
      let(:order) { build(factory) }
      it_behaves_like "it has the expected attributes"
    end

    context "when created" do
      let(:order) { create(factory) }
      it_behaves_like "it has the expected attributes"
    end
  end

  describe 'order with totals' do
    let(:factory) { :order_with_totals }

    it_behaves_like 'a working factory'

    context "when built" do
      let(:order) { build(factory, line_items_price: 77) }

      it "has all the expected attributes but total" do
        aggregate_failures do
          expect(order.total).to eq 0
          expect(order.line_items.length).to eq 1
          expect(order.line_items.first.price).to eq 77
        end
      end
    end

    context "when created" do
      let(:order) { create(factory, line_items_price: 77) }

      it "has the expected attributes" do
        aggregate_failures do
          expect(order.total).to eq order.line_items.sum(&:total)
          expect(order.line_items.length).to eq 1
          expect(order.line_items.first.price).to eq 77
        end
      end
    end
  end

  describe 'order with line items' do
    let(:factory) { :order_with_line_items }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "cart", "on_hand"
    it_behaves_like 'shipping methods are assigned'
  end

  describe 'completed order with promotion' do
    let(:factory) { :completed_order_with_promotion }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to be_complete

        expect(order.order_promotions.count).to eq(1)
        order_promotion = order.order_promotions[0]
        expect(order_promotion.promotion_code.promotion).to eq order_promotion.promotion
      end
    end

    context 'with a promotion with an action' do
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }
      it "has the expected attributes" do
        order = create(factory, promotion: promotion)
        aggregate_failures do
          expect(order).to be_completed
          expect(order).to be_complete

          expect(order.line_items[0].adjustments.count).to eq 1
          adjustment = order.line_items[0].adjustments[0]
          expect(adjustment).to have_attributes(
            amount: -10,
            eligible: true,
            order_id: order.id
          )
        end
      end
    end
  end

  describe 'order ready to complete' do
    let(:factory) { :order_ready_to_complete }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "confirm", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "is completable" do
      order = create(factory)

      expect { order.complete! }.to change {
        order.complete?
      }.from(false).to(true)
    end
  end

  describe 'completed order with totals' do
    let(:factory) { :completed_order_with_totals }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          item_total: 10,
          ship_total: 100,
          total: 110,
          state: 'complete'
        )
        expect(order.inventory_units.where(pending: true)).to be_empty
        expect(order.inventory_units.where(pending: false)).to_not be_empty
      end
    end
  end

  describe 'completed order with pending payment' do
    let(:factory) { :completed_order_with_pending_payment }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          payment_state: 'balance_due',
          total: 110,
          payment_total: 0 # payment is still pending
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'pending'
        )
      end
    end
  end

  describe 'order ready to ship' do
    let(:factory) { :order_ready_to_ship }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          total: 110,
          payment_total: 110,
          payment_state: "paid",
          shipment_state: "ready"
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'completed'
        )

        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          state: 'ready'
        )
      end
    end

    it "can be shipped" do
      order = create(factory)
      order.shipments[0].ship
      aggregate_failures do
        expect(order.shipment_state).to eq "shipped"
        expect(order.shipments[0]).to be_shipped
      end
    end
  end

  describe 'shipped order' do
    let(:factory) { :shipped_order }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "shipped"
    it_behaves_like 'shipping methods are assigned'
    it_behaves_like 'supplied completed_at is respected'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          total: 110,
          payment_total: 110,
          payment_state: "paid",
          shipment_state: "shipped"
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'completed'
        )

        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          state: 'shipped'
        )

        expect(order.cartons.count).to eq 1
      end
    end
  end
end
