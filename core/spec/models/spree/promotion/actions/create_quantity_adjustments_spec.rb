# frozen_string_literal: true

require "rails_helper"

module Spree::Promotion::Actions
  RSpec.describe CreateQuantityAdjustments do
    let(:action) { CreateQuantityAdjustments.create!(calculator: calculator, promotion: promotion) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_attributes: line_items_attributes
      )
    end

    let(:line_items_attributes) do
      [
        { price: 10, quantity: quantity }
      ]
    end

    let(:quantity) { 1 }
    let(:promotion) { FactoryBot.create :promotion }

    describe "#compute_amount" do
      subject { action.compute_amount(line_item) }

      context "with a flat rate adjustment" do
        let(:calculator) { FactoryBot.create :flat_rate_calculator, preferred_amount: 5 }

        context "with a quantity group of 2" do
          let(:line_item) { order.line_items.first }

          before { action.preferred_group_size = 2 }

          context "and an item with a quantity of 0" do
            let(:quantity) { 0 }
            it { is_expected.to eq 0 }
          end

          context "and an item with a quantity of 1" do
            let(:quantity) { 1 }
            it { is_expected.to eq 0 }
          end

          context "and an item with a quantity of 2" do
            let(:quantity) { 2 }
            it { is_expected.to eq(-10) }
          end

          context "and an item with a quantity of 3" do
            let(:quantity) { 3 }
            it { is_expected.to eq(-10) }
          end

          context "and an item with a quantity of 4" do
            let(:quantity) { 4 }
            it { is_expected.to eq(-20) }
          end
        end

        context "with a quantity group of 3" do
          before { action.preferred_group_size = 3 }

          context "and 2x item A, 1x item B and 1x item C" do
            let(:line_items_attributes) do
              [
                { price: 10, quantity: 2 },
                { price: 10, quantity: 1 },
                { price: 10, quantity: 1 },
              ]
            end

            before { action.perform({ order: order, promotion: promotion }) }

            describe "the adjustment for the first item" do
              let(:line_item) { order.line_items.first }
              it { is_expected.to eq(-10) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { order.line_items.second }
              it { is_expected.to eq(-5) }
            end
            describe "the adjustment for the third item" do
              let(:line_item) { order.line_items.third }
              it { is_expected.to eq 0 }
            end
          end
        end

        context "with multiple orders using the same action" do
          let(:other_order) do
            create(
              :order_with_line_items,
              line_items_attributes: [
                { quantity: 3 }
            ]
            )
          end

          let(:line_item) { other_order.line_items.first }

          before do
            action.preferred_group_size = 2
            action.perform({ order: other_order, promotion: promotion })
          end

          it { is_expected.to eq(-10) }
        end
      end

      context "with a percentage based adjustment" do
        let(:calculator) { FactoryBot.create :percent_on_item_calculator, preferred_percent: 10 }

        let(:line_items_attributes) do
          [
            { price: 10, quantity: 1 }.merge(line_one_options),
            { price: 10, quantity: 1 }.merge(line_two_options),
          ]
        end

        let(:line_one_options) { {} }
        let(:line_two_options) { {} }

        context "with a quantity group of 3" do
          before do
            action.preferred_group_size = 3
            action.perform({ order: order, promotion: promotion })
          end

          context "and 2x item A and 1x item B" do
            let(:line_one_options) { { quantity: 2 } }

            describe "the adjustment for the first item" do
              let(:line_item) { order.line_items.first }
              it { is_expected.to eq(-2) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { order.line_items.second }
              it { is_expected.to eq(-1) }
            end
          end

          context "and the items cost different amounts" do
            let(:line_one_options) { { quantity: 3 } }
            let(:line_two_options) { { price: 20 } }

            describe "the adjustment for the first item" do
              let(:line_item) { order.line_items.first }
              it { is_expected.to eq(-3) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { order.line_items.second }
              it { is_expected.to eq 0 }
            end
          end
        end
      end

      context "with a tiered percentage based adjustment" do
        let(:tiers) do
          {
            20 => 20,
            40 => 30
          }
        end

        let(:calculator) do
          Spree::Calculator::TieredPercent.create(preferred_base_percent: 10, preferred_tiers: tiers)
        end
        let(:line_items_attributes) do
          [
            { price: 10, quantity: 1 }.merge(line_one_options),
            { price: 10, quantity: 1 }.merge(line_two_options),
          ]
        end

        let(:line_one_options) { {} }
        let(:line_two_options) { {} }

        context "with a quantity group of 3" do
          before do
            action.preferred_group_size = 3
            action.perform({ order: order, promotion: promotion })
          end

          context "and 2x item A and 1x item B" do
            let(:line_one_options) { { quantity: 2 } }

            context "when amount falls within the first tier" do
              describe "the adjustment for the first item" do
                let(:line_item) { order.line_items.first }
                it { is_expected.to eq(-4) }
              end
              describe "the adjustment for the second item" do
                let(:line_item) { order.line_items.second }
                it { is_expected.to eq(-2) }
              end
            end

            context "when amount falls within the second tier" do
              let(:line_two_options) { { price: 20 } }

              describe "the adjustment for the first item" do
                let(:line_item) { order.line_items.first }
                it { is_expected.to eq(-6) }
              end

              describe "the adjustment for the second item" do
                let(:line_item) { order.line_items.second }
                it { is_expected.to eq(-6) }
              end
            end
          end
        end
      end
    end

    # Regression test for https://github.com/solidusio/solidus/pull/1591
    context "with unsaved line_item changes" do
      let(:calculator) { FactoryBot.create :flat_rate_calculator }
      let(:line_item) { order.line_items.first }

      before do
        order.line_items.first.promo_total = -11
        action.compute_amount(line_item)
      end

      it "doesn't reload the line_items association" do
        expect(order.line_items.first.promo_total).to eq(-11)
      end
    end

    # Regression test for https://github.com/solidusio/solidus/pull/1591
    context "applied to the order" do
      let(:calculator) { FactoryBot.create :flat_rate_calculator }

      before do
        action.perform(order: order, promotion: promotion)
        order.recalculate
      end

      it 'updates the order totals' do
        expect(order).to have_attributes(
          total: 100,
          adjustment_total: -10
        )
      end

      context "after updating item quantity" do
        before do
          order.line_items.first.update!(quantity: 2, price: 30)
          order.recalculate
        end

        it 'updates the order totals' do
          expect(order).to have_attributes(
            total: 140,
            adjustment_total: -20
          )
        end
      end

      context "after updating promotion amount" do
        before do
          calculator.update!(preferred_amount: 5)
          order.recalculate
        end

        it 'updates the order totals' do
          expect(order).to have_attributes(
            total: 105,
            adjustment_total: -5
          )
        end
      end
    end

    describe Spree::Promotion::Actions::CreateQuantityAdjustments::PartialLineItem do
      let!(:item) { FactoryBot.create :line_item, order: order, quantity: quantity, price: 10 }
      let(:quantity) { 5 }

      subject { described_class.new(item) }

      it "has a reference to the parent order" do
        expect(subject.order.id).to eq order.id
      end

      it "uses the `line_item.price` as a `line_item.amount`" do
        expect(subject.amount).to eq item.price
      end

      it "has a currency" do
        expect(subject.currency).to eq item.currency
      end
    end
  end
end
