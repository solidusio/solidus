# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe OrderUpdater, type: :model do
    let!(:store) { create :store }
    let(:order) { Spree::Order.create }
    let(:updater) { Spree::OrderUpdater.new(order) }

    context "order totals" do
      before do
        2.times do
          create(:line_item, order:, price: 10)
        end
      end

      context 'with refund' do
        it "updates payment totals" do
          create(:payment_with_refund, order:, amount: 33.25, refund_amount: 3)
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
        create(:shipment, order:, cost: 10)
        expect {
          updater.recalculate
        }.to change { order.shipment_total }.to 10
      end

      context 'with a source-less line item adjustment' do
        let(:line_item) { create(:line_item, order:, price: 10) }
        before do
          create(:adjustment, source: nil, adjustable: line_item, order:, amount: -5)
        end

        it "updates the line item total" do
          expect { updater.recalculate }.to change { line_item.reload.adjustment_total }.from(0).to(-5)
        end
      end

      it "update order adjustments" do
        create(:adjustment, adjustable: order, order:, source: nil, amount: 10)

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
          order.recalculate
        end
      end

      describe 'tax recalculation' do
        let(:tax_category) { create(:tax_category) }
        let(:ship_address) { create(:address, state: new_york) }
        let(:new_york) { create(:state, state_code: "NY") }
        let(:new_york_tax_zone) { create(:zone, states: [new_york]) }

        let!(:new_york_tax_rate) do
          create(
            :tax_rate,
            name: "New York Sales Tax",
            tax_categories: [tax_category],
            zone: new_york_tax_zone,
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
              order.recalculate
            }.to change {
              line_item.additional_tax_total
            }.from(1).to(2)
          end
        end

        context 'when the address has changed to a different state' do
          let(:oregon) { create(:state, state_code: "OR") }
          let(:oregon_tax_zone) { create(:zone, states: [oregon]) }
          let!(:oregon_tax_rate) do
            create(
              :tax_rate,
              name: "Oregon Sales Tax",
              tax_categories: [tax_category],
              zone: oregon_tax_zone,
              included_in_price: false,
              amount: 0.2
            )
          end
          let(:new_address) { create(:address, state: oregon) }
          let(:shipping_method) { create(:shipping_method, tax_category:, zones: [oregon_tax_zone, new_york_tax_zone], cost: 10) }
          let(:shipping_rate) do
            create(:shipping_rate, cost: 10, shipping_method: shipping_method)
          end
          let(:shipment) { order.shipments[0] }

          subject do
            order.ship_address = new_address
            order.bill_address = new_address

            order.recalculate
          end

          before do
            shipment.shipping_rates = [shipping_rate]
            shipment.selected_shipping_rate_id = shipping_rate.id
            order.recalculate
          end

          it 'updates the taxes to reflect the new state' do
            expect {
              subject
            }.to change {
              order.additional_tax_total
            }.from(2).to(4)
          end

          it 'updates the shipment taxes to reflect the new state' do
            expect {
              subject
            }.to change {
              order.shipments.first.additional_tax_total
            }.from(1).to(2)
            .and change {
              order.shipments.first.adjustments.first.amount
            }.from(1).to(2)
          end

          it 'updates the line item taxes to reflect the new state' do
            expect {
              subject
            }.to change {
              order.line_items.first.additional_tax_total
            }.from(1).to(2)
            .and change {
              order.line_items.first.adjustments.first.amount
            }.from(1).to(2)
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

          before { order.recalculate }

          it "updates the order-level tax adjustment" do
            expect {
              order.ship_address = create(:address)
              order.recalculate
            }.to change { order.additional_tax_total }.from(0.27).to(0).
                and change { order.adjustment_total }.from(0.27).to(0)
          end

          it "deletes the order-level tax adjustments when it persists the order" do
            expect {
              order.ship_address = create(:address)
              order.recalculate
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
                    tax_rate: new_york_tax_rate,
                    amount: 2.60,
                    included_in_price: false
                  )
                ],
                line_item_taxes: [
                  Spree::Tax::ItemTax.new(
                    item_id: line_item.id,
                    label: "Item Tax",
                    tax_rate: new_york_tax_rate,
                    amount: 1.40,
                    included_in_price: false
                  )
                ],
                shipment_taxes: []
              )
            )
          end

          it 'uses the configured class' do
            order.recalculate

            expect(custom_calculator_class).to have_received(:new).with(order).at_least(:once)
            expect(custom_calculator_instance).to have_received(:calculate).at_least(:once)
          end

          it 'updates the aggregate columns' do
            expect {
              order.recalculate
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

      it "logs a state change for the shipment" do
        create :shipment, order:, state: "pending"

        expect { updater.recalculate_shipment_state }
          .to enqueue_job(Spree::StateChangeTrackingJob)
          .with(order, nil, "pending", a_kind_of(Time), "shipment")
          .once

        expect {
          perform_enqueued_jobs
        }.to change { Spree::StateChange.where(name: "shipment").count }.by(1)
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
          create(:shipment, order:, state:)
          updater.recalculate_shipment_state
          expect(order.shipment_state).to eq(state)
        end
      end

      it "is partial" do
        create(:shipment, order:, state: 'pending')
        create(:shipment, order:, state: 'ready')
        updater.recalculate_shipment_state
        expect(order.shipment_state).to eq('partial')
      end
    end

    context "updating payment state" do
      let(:order) { create(:order) }
      let(:updater) { order.recalculator }
      before { allow(order).to receive(:refund_total).and_return(0) }

      it "logs a state change for the payment" do
        create :payment, order:, state: "processing"

        expect { updater.recalculate_payment_state }
          .to enqueue_job(Spree::StateChangeTrackingJob)
          .with(order, nil, "paid", a_kind_of(Time), "payment")
          .once

        expect {
          perform_enqueued_jobs
        }.to change { Spree::StateChange.where(name: "payment").count }.by(1)
      end

      context 'no valid payments with non-zero order total' do
        it "is failed" do
          create(:payment, order:, state: 'invalid')
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
            create(:payment, order:, state: 'completed', amount: 30)
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
        before { create(:shipment, order:) }
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
      let!(:line_item) { create(:line_item, order:, price: 10) }

      it "updates the totals" do
        line_item.update!(adjustment_total: 100)
        expect {
          order.recalculate
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
        order.recalculate

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
