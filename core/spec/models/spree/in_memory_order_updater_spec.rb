# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe InMemoryOrderUpdater, type: :model do
    let!(:store) { create :store }
    let(:order) { Spree::Order.create }
    let(:updater) { described_class.new(order) }

    describe "#recalculate" do
      subject { updater.recalculate(persist:) }

      let(:new_store) { create(:store) }

      context "when the persist flag is set to 'false'" do
        let(:persist) { false }

        it "does not persist changes to order" do
          order.store = new_store

          expect {
            subject
          }.not_to make_database_queries(manipulative: true)

          expect(order.store).to eq new_store
          expect(order.reload.store).not_to eq new_store
        end

        it "does not persist changes to the item count" do
          order.line_items << build(:line_item)

          expect {
            subject
          }.not_to make_database_queries(manipulative: true)

          expect(order.item_count).to eq 1
          expect(order.reload.item_count).to eq 0
        end

        context 'when a shipment is attached to the order' do
          let(:shipment) { create(:shipment) }

          before do
            order.shipments << shipment
          end

          it 'does not make manipulative database queries' do
            expect {
              subject
            }.not_to make_database_queries(manipulative: true)
          end

          context 'when the shipment has a selected shipping rate' do
            let(:shipment) { create(:shipment, shipping_rates: [build(:shipping_rate, selected: true)]) }

            it 'does not make manipulative database queries' do
              expect {
                subject
              }.not_to make_database_queries(manipulative: true)
            end
          end
        end
      end

      context "when the persist flag is set to 'true'" do
        let(:persist) { true }

        it "persists any changes to order" do
          order.store = new_store

          expect {
            subject
          }.to make_database_queries(manipulative: true)

          expect(order.reload.store).to eq new_store
        end
      end
    end

    context "order totals" do
      before do
        2.times do
          create(:line_item, order: order, price: 10)
        end
      end

      context 'with refund' do
        it "updates payment totals" do
          create(:payment_with_refund, order: order, amount: 33.25, refund_amount: 3)
          updater.recalculate
          expect(order.payment_total).to eq(30.25)
        end
      end

      it "update item total" do
        expect {
          updater.recalculate
        }.to change { order.item_total }.to 20
      end

      it "update shipment total" do
        create(:shipment, order: order, cost: 10)
        expect {
          updater.recalculate
        }.to change { order.shipment_total }.to 10
      end

      context 'with a source-less line item adjustment' do
        let(:line_item) { create(:line_item, order: order, price: 10) }
        before do
          create(:adjustment, source: nil, adjustable: line_item, order: order, amount: -5)
        end

        it "updates the line item total" do
          expect { updater.recalculate }.to change { line_item.reload.adjustment_total }.from(0).to(-5)
        end
      end

      it "update order adjustments" do
        create(:adjustment, adjustable: order, order: order, source: nil, amount: 10)

        expect {
          updater.recalculate
        }.to change {
          order.adjustment_total
        }.from(0).to(10)
      end
    end

    describe '#recalculate_adjustments ' do
      describe 'promotion recalculation' do
        it "calls the Promotion Adjustments Recalculator" do
          adjuster = double(:call)
          expect(Spree::Config.promotions.order_adjuster_class).to receive(:new).and_return(adjuster)
          expect(adjuster).to receive(:call)
          updater.recalculate
        end
      end

      describe 'tax recalculation' do
        let(:tax_category) { create(:tax_category) }
        let(:ship_address) { create(:address, state: new_york) }
        let(:new_york) { create(:state, state_code: "NY") }
        let(:tax_zone) { create(:zone, states: [new_york]) }

        let!(:tax_rate) do
          create(
            :tax_rate,
            name: "New York Sales Tax",
            tax_categories: [tax_category],
            zone: tax_zone,
            included_in_price: false,
            amount: 0.1
          )
        end

        let(:order) do
          create(
            :order_with_line_items,
            line_items_attributes: [{ price: 10, variant: variant }],
            ship_address: ship_address,
          )
        end
        let(:line_item) { order.line_items[0] }

        let(:variant) { create(:variant, tax_category:) }

        context 'when the item quantity has changed' do
          before do
            line_item.update!(quantity: 2)
          end

          it 'updates the additional_tax_total' do
            expect {
              updater.recalculate
            }.to change {
              line_item.additional_tax_total
            }.from(1).to(2)
          end
        end

        context 'when the address has changed to a different state' do
          let(:new_shipping_address) { create(:address) }

          before do
            order.ship_address = new_shipping_address
          end

          it 'removes the old taxes' do
            expect {
              updater.recalculate
            }.to change {
              order.all_adjustments.tax.count
            }.from(1).to(0)

            expect(order.additional_tax_total).to eq 0
            expect(order.adjustment_total).to eq 0
          end
        end

        context "with an order-level tax adjustment" do
          let(:colorado) { create(:state, state_code: "CO") }
          let(:colorado_tax_zone) { create(:zone, states: [colorado]) }
          let(:ship_address) { create(:address, state: colorado) }

          let!(:colorado_delivery_fee) do
            create(
              :tax_rate,
              amount: 0.27,
              calculator: Spree::Calculator::FlatFee.new,
              level: "order",
              name: "Colorado Delivery Fee",
              tax_categories: [tax_category],
              zone: colorado_tax_zone
            )
          end

          before { updater.recalculate }

          it "updates the order-level tax adjustment" do
            expect {
              order.ship_address = create(:address)
              updater.recalculate
            }.to change { order.additional_tax_total }.from(0.27).to(0).
                and change { order.adjustment_total }.from(0.27).to(0)
          end

          it "deletes the order-level tax adjustments when it persists the order" do
            expect {
              order.ship_address = create(:address)
              updater.recalculate
            }.to change { order.all_adjustments.count }.from(1).to(0)
          end
        end

        context 'with a custom tax_calculator_class' do
          let(:custom_calculator_class) { double }
          let(:custom_calculator_instance) { double }

          before do
            order # generate this first so we can expect it
            stub_spree_preferences(tax_calculator_class: custom_calculator_class)

            allow(custom_calculator_class).to receive(:new).and_return(custom_calculator_instance)
            allow(custom_calculator_instance).to receive(:calculate).and_return(
              Spree::Tax::OrderTax.new(
                order_id: order.id,
                order_taxes: [
                  Spree::Tax::ItemTax.new(
                    label: "Delivery Fee",
                    tax_rate:,
                    amount: 2.60,
                    included_in_price: false
                  )
                ],
                line_item_taxes: [
                  Spree::Tax::ItemTax.new(
                    item_id: line_item.id,
                    label: "Item Tax",
                    tax_rate:,
                    amount: 1.40,
                    included_in_price: false
                  )
                ],
                shipment_taxes: []
              )
            )
          end

          it 'uses the configured class' do
            updater.recalculate

            expect(custom_calculator_class).to have_received(:new).with(order).at_least(:once)
            expect(custom_calculator_instance).to have_received(:calculate).at_least(:once)
          end

          it 'updates the aggregate columns' do
            expect {
              updater.recalculate
            }.to change { order.reload.additional_tax_total }.to(4.00)
              .and change { order.reload.adjustment_total }.to(4.00)
          end
        end
      end
    end

    context "updating shipment state" do
      before do
        allow(order).to receive_messages backordered?: false
      end

      it "is backordered" do
        allow(order).to receive_messages backordered?: true
        updater.recalculate_shipment_state

        expect(order.shipment_state).to eq('backorder')
      end

      it "is nil" do
        updater.recalculate_shipment_state
        expect(order.shipment_state).to be_nil
      end

      ["shipped", "ready", "pending"].each do |state|
        it "is #{state}" do
          create(:shipment, order: order, state: state)
          updater.recalculate_shipment_state
          expect(order.shipment_state).to eq(state)
        end
      end

      it "is partial" do
        create(:shipment, order: order, state: 'pending')
        create(:shipment, order: order, state: 'ready')
        updater.recalculate_shipment_state
        expect(order.shipment_state).to eq('partial')
      end
    end

    context "updating payment state" do
      let(:order) { build(:order) }
      before { allow(order).to receive(:refund_total).and_return(0) }

      context 'no valid payments with non-zero order total' do
        it "is failed" do
          create(:payment, order: order, state: 'invalid')
          order.total = 1
          order.payment_total = 0

          updater.recalculate_payment_state
          expect(order.payment_state).to eq('failed')
        end
      end

      context 'invalid payments are present but order total is zero' do
        it 'is paid' do
          order.payments << Spree::Payment.new(state: 'invalid')
          order.total = 0
          order.payment_total = 0

          expect {
            updater.recalculate_payment_state
          }.to change { order.payment_state }.to 'paid'
        end
      end

      context "payment total is greater than order total" do
        it "is credit_owed" do
          order.payment_total = 2
          order.total = 1

          expect {
            updater.recalculate_payment_state
          }.to change { order.payment_state }.to 'credit_owed'
        end
      end

      context "order total is greater than payment total" do
        it "is balance_due" do
          order.payment_total = 1
          order.total = 2

          expect {
            updater.recalculate_payment_state
          }.to change { order.payment_state }.to 'balance_due'
        end
      end

      context "order total equals payment total" do
        it "is paid" do
          order.payment_total = 30
          order.total = 30

          expect {
            updater.recalculate_payment_state
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
              updater.recalculate_payment_state
            }.to change { order.payment_state }.to 'void'
          end
        end

        context "and is paid" do
          it "is credit_owed" do
            order.payment_total = 30
            order.total = 30
            create(:payment, order: order, state: 'completed', amount: 30)
            expect {
              updater.recalculate_payment_state
            }.to change { order.payment_state }.to 'credit_owed'
          end
        end

        context "and payment is refunded" do
          it "is void" do
            order.payment_total = 0
            order.total = 30
            expect {
              updater.recalculate_payment_state
            }.to change { order.payment_state }.to 'void'
          end
        end
      end
    end

    context "completed order" do
      before { allow(order).to receive_messages completed?: true }

      it "updates payment state" do
        expect(updater).to receive(:recalculate_payment_state)
        updater.recalculate
      end

      it "updates shipment state" do
        expect(updater).to receive(:recalculate_shipment_state)
        updater.recalculate
      end

      context 'with a shipment' do
        before { create(:shipment, order: order) }
        let(:shipment){ order.shipments[0] }

        it "updates each shipment" do
          expect(shipment).to receive(:update_state)
          updater.recalculate
        end

        it "updates the shipment amount" do
          expect(shipment).to receive(:update_amounts)
          updater.recalculate
        end
      end
    end

    context "incompleted order" do
      before { allow(order).to receive_messages completed?: false }

      it "doesnt update payment state" do
        expect(updater).not_to receive(:recalculate_payment_state)
        updater.recalculate
      end

      it "doesnt update shipment state" do
        expect(updater).not_to receive(:recalculate_shipment_state)
        updater.recalculate
      end

      it "doesnt update each shipment" do
        shipment = stub_model(Spree::Shipment)
        order.shipments = [shipment]
        allow(order.shipments).to receive_messages(states: [], ready: [], pending: [], shipped: [])
        allow(updater).to receive(:update_totals) # Otherwise this gets called and causes a scene
        expect(updater).not_to receive(:update_shipments)
        updater.recalculate
      end
    end

    context "with item with no adjustment and incorrect totals" do
      let!(:line_item) { create(:line_item, order: order, price: 10) }

      it "updates the totals" do
        line_item.update!(adjustment_total: 100)
        expect {
          updater.recalculate
        }.to change { line_item.reload.adjustment_total }.from(100).to(0)
      end
    end

    context "with 'order_recalculated' event subscription" do
      let(:item) { spy('object') }
      let(:bus) { Spree::Bus }

      let!(:subscription) do
        bus.subscribe :order_recalculated do
          item.do_something
        end
      end

      after { bus.unsubscribe subscription }

      it "fires the 'order_recalculated' event" do
        updater.recalculate

        expect(item).to have_received(:do_something)
      end
    end

    context "with invalid associated objects" do
      let(:order) { Spree::Order.create(ship_address: Spree::Address.new) }
      subject { updater.recalculate }

      it "raises because of the invalid object" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
