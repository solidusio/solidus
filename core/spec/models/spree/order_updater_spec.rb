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
          updater.recalculate
          create(:adjustment, source: promotion_action, adjustable: order, order: order)
          create(:line_item, order: order, price: 10) # in addition to the two already created
          order.line_items.reload # need to pick up the extra line item
          updater.recalculate
        end

        it "updates promotion total" do
          expect(order.promo_total).to eq(-3)
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
          expect(Spree::Promotion::OrderAdjustmentsRecalculator).to receive(:new).and_return(adjuster)
          expect(adjuster).to receive(:call)
          order.recalculate
        end
      end

      describe 'tax recalculation' do
        let!(:ship_address) { create(:address) }
        let!(:tax_zone) { create(:global_zone) } # will include the above address
        let!(:tax_rate) { create(:tax_rate, zone: tax_zone, tax_categories: [tax_category]) }

        let(:order) do
          create(
            :order_with_line_items,
            line_items_attributes: [{ price: 10, variant: variant }],
            ship_address: ship_address,
          )
        end
        let(:line_item) { order.line_items[0] }

        let(:variant) { create(:variant, tax_category: tax_category) }
        let(:tax_category) { create(:tax_category) }

        context 'when the item quantity has changed' do
          before do
            line_item.update!(quantity: 2)
          end

          it 'updates the promotion amount' do
            expect {
              order.recalculate
            }.to change {
              line_item.additional_tax_total
            }.from(1).to(2)
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
                    tax_rate: tax_rate,
                    amount: 2.60,
                    included_in_price: false
                  )
                ],
                line_item_taxes: [
                  Spree::Tax::ItemTax.new(
                    item_id: line_item.id,
                    label: "Item Tax",
                    tax_rate: tax_rate,
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
      let(:order) { build(:order) }
      let(:updater) { order.recalculator }
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

    context "completed order" do
      before { allow(order).to receive_messages completed?: true }

      it "updates payment state" do
        expect(updater).to receive(:update_payment_state)
        updater.recalculate
      end

      it "updates shipment state" do
        expect(updater).to receive(:update_shipment_state)
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
        expect(updater).not_to receive(:update_payment_state)
        updater.recalculate
      end

      it "doesnt update shipment state" do
        expect(updater).not_to receive(:update_shipment_state)
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

        order.recalculate

        expect(line_item.promo_total).to eq(-1)
        expect(order.promo_total).to eq(-1)
      end
    end

    context "with item with no adjustment and incorrect totals" do
      let!(:line_item) { create(:line_item, order: order, price: 10) }

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
