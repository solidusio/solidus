require 'spec_helper'

module Spree
  describe OrderUpdater, type: :model do
    let!(:store) { create :store }
    let(:order) { Spree::Order.create }
    let(:updater) { Spree::OrderUpdater.new(order) }

    context "order totals" do
      before do
        2.times do
          create(:line_item, order: order, price: 10)
        end
      end

      context 'with refund' do
        it "updates payment totals" do
          create(:payment_with_refund, order: order, amount: 33.25, refund_amount: 3)
          Spree::OrderUpdater.new(order).update_payment_total
          expect(order.payment_total).to eq(30.25)
        end
      end

      it "update item total" do
        updater.update_item_total
        expect(order.item_total).to eq(20)
      end

      it "update shipment total" do
        create(:shipment, order: order, cost: 10)
        updater.update_shipment_total
        expect(order.shipment_total).to eq(10)
      end

      context 'with order promotion followed by line item addition' do
        let(:promotion) { Spree::Promotion.create!(name: "10% off") }
        let(:calculator) { Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }

        let(:promotion_action) do
          Promotion::Actions::CreateAdjustment.create!({
            calculator: calculator,
            promotion: promotion
          })
        end

        before do
          updater.update
          create(:adjustment, source: promotion_action, adjustable: order, order: order)
          create(:line_item, order: order, price: 10) # in addition to the two already created
          order.line_items.reload # need to pick up the extra line item
          updater.update
        end

        it "updates promotion total" do
          expect(order.promo_total).to eq(-3)
        end
      end

      it "update order adjustments" do
        create(:adjustment, adjustable: order, order: order, source: nil, amount: 10)

        expect {
          updater.update_adjustment_total
        }.to change {
          order.adjustment_total
        }.from(0).to(10)
      end
    end

    context "updating shipment state" do
      before do
        allow(order).to receive_messages backordered?: false
      end

      it "is backordered" do
        allow(order).to receive_messages backordered?: true
        updater.update_shipment_state

        expect(order.shipment_state).to eq('backorder')
      end

      it "is nil" do
        updater.update_shipment_state
        expect(order.shipment_state).to be_nil
      end

      ["shipped", "ready", "pending"].each do |state|
        it "is #{state}" do
          create(:shipment, order: order, state: state)
          updater.update_shipment_state
          expect(order.shipment_state).to eq(state)
        end
      end

      it "is partial" do
        create(:shipment, order: order, state: 'pending')
        create(:shipment, order: order, state: 'ready')
        updater.update_shipment_state
        expect(order.shipment_state).to eq('partial')
      end
    end

    context "updating payment state" do
      let(:order) { Order.new }
      let(:updater) { order.updater }
      before { allow(order).to receive(:refund_total).and_return(0) }

      context 'no valid payments with non-zero order total' do
        it "is failed" do
          create(:payment, order: order, state: 'invalid')
          order.total = 1
          order.payment_total = 0

          updater.update_payment_state
          expect(order.payment_state).to eq('failed')
        end
      end

      context 'invalid payments are present but order total is zero' do
        it 'is paid' do
          order.payments << Spree::Payment.new(state: 'invalid')
          order.total = 0
          order.payment_total = 0

          expect {
            updater.update_payment_state
          }.to change { order.payment_state }.to 'paid'
        end
      end

      context "payment total is greater than order total" do
        it "is credit_owed" do
          order.payment_total = 2
          order.total = 1

          expect {
            updater.update_payment_state
          }.to change { order.payment_state }.to 'credit_owed'
        end
      end

      context "order total is greater than payment total" do
        it "is balance_due" do
          order.payment_total = 1
          order.total = 2

          expect {
            updater.update_payment_state
          }.to change { order.payment_state }.to 'balance_due'
        end
      end

      context "order total equals payment total" do
        it "is paid" do
          order.payment_total = 30
          order.total = 30

          expect {
            updater.update_payment_state
          }.to change { order.payment_state }.to 'paid'
        end
      end

      context "order is canceled" do
        before do
          order.state = 'canceled'
        end

        context "and is still unpaid" do
          it "is void" do
            order.payment_total = 0
            order.total = 30
            expect {
              updater.update_payment_state
            }.to change { order.payment_state }.to 'void'
          end
        end

        context "and is paid" do
          it "is credit_owed" do
            order.payment_total = 30
            order.total = 30
            create(:payment, order: order, state: 'completed', amount: 30)
            expect {
              updater.update_payment_state
            }.to change { order.payment_state }.to 'credit_owed'
          end
        end

        context "and payment is refunded" do
          it "is void" do
            order.payment_total = 0
            order.total = 30
            expect {
              updater.update_payment_state
            }.to change { order.payment_state }.to 'void'
          end
        end
      end
    end

    it "state change" do
      order.shipment_state = 'shipped'
      state_changes = double
      allow(order).to receive_messages state_changes: state_changes
      expect(state_changes).to receive(:create).with(
        previous_state: nil,
        next_state: 'shipped',
        name: 'shipment',
        user_id: nil
      )

      order.state_changed('shipment')
    end

    context "completed order" do
      before { allow(order).to receive_messages completed?: true }

      it "updates payment state" do
        expect(updater).to receive(:update_payment_state)
        updater.update
      end

      it "updates shipment state" do
        expect(updater).to receive(:update_shipment_state)
        updater.update
      end

      context 'with a shipment' do
        before { create(:shipment, order: order) }
        let(:shipment){ order.shipments[0] }

        it "updates each shipment" do
          expect(shipment).to receive(:update!)
          updater.update_shipments
        end

        it "refreshes shipment rates" do
          expect(shipment).to receive(:refresh_rates)
          updater.update_shipments
        end

        it "updates the shipment amount" do
          expect(shipment).to receive(:update_amounts)
          updater.update_shipments
        end
      end
    end

    context "incompleted order" do
      before { allow(order).to receive_messages completed?: false }

      it "doesnt update payment state" do
        expect(updater).not_to receive(:update_payment_state)
        updater.update
      end

      it "doesnt update shipment state" do
        expect(updater).not_to receive(:update_shipment_state)
        updater.update
      end

      it "doesnt update each shipment" do
        shipment = stub_model(Spree::Shipment)
        shipments = [shipment]
        allow(order).to receive_messages shipments: shipments
        allow(shipments).to receive_messages states: []
        allow(shipments).to receive_messages ready: []
        allow(shipments).to receive_messages pending: []
        allow(shipments).to receive_messages shipped: []

        allow(updater).to receive(:update_totals) # Otherwise this gets called and causes a scene
        expect(updater).not_to receive(:update_shipments).with(order)
        updater.update
      end
    end

    describe 'updating in-memory items' do
      let(:order) do
        create(:order_with_line_items, line_items_count: 1, line_items_price: 10)
      end
      let(:line_item) { order.line_items.first }
      let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 1) }

      it 'updates in-memory items' do
        promotion.activate(order: order)

        expect(line_item.promo_total).to eq(0)
        expect(order.promo_total).to eq(0)

        order.update!

        expect(line_item.promo_total).to eq(-1)
        expect(order.promo_total).to eq(-1)
      end
    end

    context "with item with no adjustment and incorrect totals" do
      let!(:line_item) { create(:line_item, order: order, price: 10) }

      it "updates the totals" do
        line_item.update!(adjustment_total: 100)
        expect {
          order.update!
        }.to change { line_item.reload.adjustment_total }.from(100).to(0)
      end
    end
  end
end
