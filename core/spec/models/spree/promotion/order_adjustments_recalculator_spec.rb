# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::OrderAdjustmentsRecalculator do
  subject { described_class.new(order).adjust! }

  describe '#adjust! ' do
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
            subject
          }.to change {
            line_item.adjustments.first.amount
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
          expect { subject }.to raise_error('Custom promotion chooser')
        end
      end

      context 'default promotion chooser (best promotion is always applied)' do
        include ActiveSupport::Testing::TimeHelpers

        let(:calculator) { Spree::Calculator::FlatRate.new(preferred_amount: 10) }

        let(:source) do
          Spree::Promotion::Actions::CreateItemAdjustments.create!(
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

          subject

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

          subject

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

          subject

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

                subject
                order.reload
                expect(order.all_adjustments.count).to eq(2), 'Expected two adjustments'
                expect(order.all_adjustments.eligible.count).to eq(1), 'Expected one elegible adjustment'
                expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo1), 'Expected promo1 to be used'

                # This will call the described class
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
            subject
            expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion A')
          end
        end

        it 'should only leave one adjustment even if 2 have the same amount' do
          create_adjustment('Promotion A', -100)
          create_adjustment('Promotion B', -200)
          create_adjustment('Promotion C', -200)

          subject

          expect(line_item.adjustments.promotion.eligible.count).to eq(1)
          expect(line_item.adjustments.promotion.eligible.first.amount.to_i).to eq(-200)
        end
      end
    end
  end
end
