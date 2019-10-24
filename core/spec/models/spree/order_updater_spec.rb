# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe OrderUpdater, type: :model do
    include ActiveSupport::Testing::TimeHelpers

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
          updater.update
          expect(order.payment_total).to eq(30.25)
        end
      end

      it "update item total" do
        expect {
          updater.update
        }.to change { order.item_total }.to 20
      end

      it "update shipment total" do
        create(:shipment, order: order, cost: 10)
        expect {
          updater.update
        }.to change { order.shipment_total }.to 10
      end

      context 'with a source-less line item adjustment' do
        let(:line_item) { create(:line_item, order: order, price: 10) }
        before do
          create(:adjustment, source: nil, adjustable: line_item, order: order, amount: -5)
        end

        it "updates the line item total" do
          expect { updater.update }.to change { line_item.reload.adjustment_total }.from(0).to(-5)
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
          updater.update
        }.to change {
          order.adjustment_total
        }.from(0).to(10)
      end
    end

    describe '#recalculate_adjustments ' do
      describe 'promotion recalculation' do
        let(:order) { create(:order_with_line_items, line_items_count: 1, line_items_price: 10) }
        let(:line_item) { order.line_items[0] }

        context 'when the item quantity has changed' do
          let(:promotion) { create(:promotion, promotion_actions: [promotion_action]) }
          let(:promotion_action) { Spree::Promotion::Actions::CreateItemAdjustments.new(calculator: calculator) }
          let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }

          before do
            promotion.activate(order: order)
            order.recalculate
            line_item.update!(quantity: 2)
          end

          it 'updates the promotion amount' do
            expect {
              order.recalculate
            }.to change {
              line_item.promo_total
            }.from(-1).to(-2)
          end
        end

        context 'promotion chooser customization' do
          before do
            class Spree::TestPromotionChooser
              def initialize(_adjustments)
                raise 'Custom promotion chooser'
              end
            end

            stub_spree_preferences(promotion_chooser_class: Spree::TestPromotionChooser)
          end

          it 'uses the defined promotion chooser' do
            expect { order.recalculate }.to raise_error('Custom promotion chooser')
          end
        end

        context 'default promotion chooser (best promotion is always applied)' do
          let(:calculator) { Calculator::FlatRate.new(preferred_amount: 10) }

          let(:source) do
            Promotion::Actions::CreateItemAdjustments.create!(
              calculator: calculator,
              promotion: promotion,
            )
          end
          let(:promotion) { create(:promotion) }

          def create_adjustment(label, amount)
            create(
              :adjustment,
              order: order,
              adjustable: line_item,
              source: source,
              amount: amount,
              finalized: true,
              label: label,
            )
          end

          it 'should make all but the most valuable promotion adjustment ineligible, leaving non promotion adjustments alone' do
            create_adjustment('Promotion A', -100)
            create_adjustment('Promotion B', -200)
            create_adjustment('Promotion C', -300)
            create(:adjustment, order: order,
                                adjustable: line_item,
                                source: nil,
                                amount: -500,
                                finalized: true,
                                label: 'Some other credit')

            line_item.adjustments.each { |item| item.update_column(:eligible, true) }

            order.recalculate

            expect(line_item.adjustments.promotion.eligible.count).to eq(1)
            expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion C')
          end

          it 'should choose the most recent promotion adjustment when amounts are equal' do
            # Freezing time is a regression test
            travel_to(Time.current) do
              create_adjustment('Promotion A', -200)
              create_adjustment('Promotion B', -200)
            end
            line_item.adjustments.each { |item| item.update_column(:eligible, true) }

            order.recalculate

            expect(line_item.adjustments.promotion.eligible.count).to eq(1)
            expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion B')
          end

          it 'should choose the most recent promotion adjustment when amounts are equal' do
            # Freezing time is a regression test
            travel_to(Time.current) do
              create_adjustment('Promotion A', -200)
              create_adjustment('Promotion B', -200)
            end
            line_item.adjustments.each { |item| item.update_column(:eligible, true) }

            order.recalculate

            expect(line_item.adjustments.promotion.eligible.count).to eq(1)
            expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion B')
          end

          context 'when previously ineligible promotions become available' do
            let(:order_promo1) { create(:promotion, :with_order_adjustment, :with_item_total_rule, weighted_order_adjustment_amount: 5, item_total_threshold_amount: 10) }
            let(:order_promo2) { create(:promotion, :with_order_adjustment, :with_item_total_rule, weighted_order_adjustment_amount: 10, item_total_threshold_amount: 20) }
            let(:order_promos) { [order_promo1, order_promo2] }
            let(:line_item_promo1) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 2.5, item_total_threshold_amount: 10, apply_automatically: true) }
            let(:line_item_promo2) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 5, item_total_threshold_amount: 20, apply_automatically: true) }
            let(:line_item_promos) { [line_item_promo1, line_item_promo2] }
            let(:order) { create(:order_with_line_items, line_items_count: 1) }

            # Apply promotions in different sequences. Results should be the same.
            promo_sequences = [
              [0, 1],
              [1, 0],
            ]

            promo_sequences.each do |promo_sequence|
              context "with promo sequence #{promo_sequence}" do
                it 'should pick the best order-level promo according to current eligibility' do
                  # apply both promos to the order, even though only promo1 is eligible
                  order_promos[promo_sequence[0]].activate order: order
                  order_promos[promo_sequence[1]].activate order: order

                  order.recalculate
                  order.reload
                  expect(order.all_adjustments.count).to eq(2), 'Expected two adjustments'
                  expect(order.all_adjustments.eligible.count).to eq(1), 'Expected one elegible adjustment'
                  expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo1), 'Expected promo1 to be used'

                  order.contents.add create(:variant, price: 10), 1
                  order.save

                  order.reload
                  expect(order.all_adjustments.count).to eq(2), 'Expected two adjustments'
                  expect(order.all_adjustments.eligible.count).to eq(1), 'Expected one elegible adjustment'
                  expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo2), 'Expected promo2 to be used'
                end

                it 'should pick the best line-item-level promo according to current eligibility' do
                  # apply both promos to the order, even though only promo1 is eligible
                  line_item_promos[promo_sequence[0]].activate order: order
                  line_item_promos[promo_sequence[1]].activate order: order

                  order.reload
                  expect(order.all_adjustments.count).to eq(1), 'Expected one adjustment'
                  expect(order.all_adjustments.eligible.count).to eq(1), 'Expected one elegible adjustment'
                  # line_item_promo1 is the only one that has thus far met the order total threshold, it is the only promo which should be applied.
                  expect(order.all_adjustments.first.source.promotion).to eq(line_item_promo1), 'Expected line_item_promo1 to be used'

                  order.contents.add create(:variant, price: 10), 1
                  order.save

                  order.reload
                  expect(order.all_adjustments.count).to eq(4), 'Expected four adjustments'
                  expect(order.all_adjustments.eligible.count).to eq(2), 'Expected two elegible adjustments'
                  order.all_adjustments.eligible.each do |adjustment|
                    expect(adjustment.source.promotion).to eq(line_item_promo2), 'Expected line_item_promo2 to be used'
                  end
                end
              end
            end
          end

          context 'multiple adjustments and the best one is not eligible' do
            let!(:promo_a) { create_adjustment('Promotion A', -100) }
            let!(:promo_c) { create_adjustment('Promotion C', -300) }

            before do
              promo_a.update_column(:eligible, true)
              promo_c.update_column(:eligible, false)
            end

            # regression for https://github.com/spree/spree/issues/3274
            it 'still makes the previous best eligible adjustment valid' do
              order.recalculate
              expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion A')
            end
          end

          it 'should only leave one adjustment even if 2 have the same amount' do
            create_adjustment('Promotion A', -100)
            create_adjustment('Promotion B', -200)
            create_adjustment('Promotion C', -200)

            order.recalculate

            expect(line_item.adjustments.promotion.eligible.count).to eq(1)
            expect(line_item.adjustments.promotion.eligible.first.amount.to_i).to eq(-200)
          end
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
          end

          it 'uses the configured class' do
            expect(custom_calculator_class).to receive(:new).with(order).at_least(:once).and_return(custom_calculator_instance)
            expect(custom_calculator_instance).to receive(:calculate).at_least(:once).and_return(
              Spree::Tax::OrderTax.new(order_id: order.id, line_item_taxes: [], shipment_taxes: [])
            )

            order.recalculate
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
          expect(shipment).to receive(:update_state)
          updater.update
        end

        it "updates the shipment amount" do
          expect(shipment).to receive(:update_amounts)
          updater.update
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
        order.shipments = [shipment]
        allow(order.shipments).to receive_messages(states: [], ready: [], pending: [], shipped: [])
        allow(updater).to receive(:update_totals) # Otherwise this gets called and causes a scene
        expect(updater).not_to receive(:update_shipments)
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
  end
end
