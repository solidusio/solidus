# frozen_string_literal: true

require "rails_helper"

module Spree::Promotion::Actions
  RSpec.describe CreateQuantityAdjustments do
    let(:action) { CreateQuantityAdjustments.create!(calculator:, promotion:) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_attributes:
      )
    end

    let(:line_items_attributes) do
      [
        { price: 10, quantity: }
      ]
    end

    let(:quantity) { 1 }
    let(:promotion) { FactoryBot.create :promotion }

    describe "#perform" do
      subject { action.perform({ order:, promotion: }) }

      let(:calculator) { FactoryBot.create :flat_rate_calculator, preferred_amount: }

      context "when calculator computes 0" do
        let(:preferred_amount) { 0 }

        it "does not create an adjustment" do
          expect { subject }
            .not_to change { action.adjustments.count }
        end
      end

      context "when calculator returns a non-zero value" do
        let(:preferred_amount) { 10 }
        let(:line_item) { order.line_items.first }

        it "creates an adjustment" do
          expect { subject }
            .to change { action.adjustments.count }
            .from(0).to(1)
            .and change { line_item.adjustments.count }
            .from(0).to(1)

          expect(line_item.adjustments).to eq(action.adjustments)
        end

        it "associates the line item with the action", :aggregate_failures do
          expect { subject }
            .to change { line_item.line_item_actions.count }
            .from(0).to(1)

          expect(action.line_item_actions.first).to have_attributes(
            line_item_id: line_item.id,
            action_id: action.id,
            quantity: 1
          )
        end
      end
    end

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

            it "doesn't save anything to the database" do
              action
              line_item

              expect {
                subject
              }.not_to make_database_queries(manipulative: true)
            end
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

            before { action.perform({ order:, promotion: }) }

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
            action.perform({ order: other_order, promotion: })
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
            action.perform({ order:, promotion: })
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
            action.perform({ order:, promotion: })
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

    describe Spree::Promotion::Actions::CreateQuantityAdjustments::PartialLineItem do
      let!(:item) { FactoryBot.create :line_item, order:, quantity:, price: 10 }
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

    describe "#available_calculators" do
      let(:action) { described_class.new }

      subject { action.available_calculators }

      it {
        is_expected.to eq(Spree::Config.promotions.calculators[described_class.to_s])
      }
    end
  end
end
