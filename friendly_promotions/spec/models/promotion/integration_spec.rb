# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Promotion System" do
  context "A promotion that creates line item adjustments" do
    let(:shirt) { create(:product) }
    let(:pants) { create(:product) }
    let(:promotion) { create(:promotion, name: "20% off Shirts", apply_automatically: true) }
    let(:order) { create(:order) }

    before do
      promotion.rules << rule
      promotion.actions << action
      order.contents.add(shirt.master, 1)
      order.contents.add(pants.master, 1)
    end

    context "with an order-level rule" do
      let(:rule) { SolidusFriendlyPromotions::Rules::Product.new(products: [shirt]) }

      context "with an order level action" do
        let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 20) }
        let(:action) { Spree::Promotion::Actions::CreateAdjustment.new(calculator: calculator) }

        it "creates one order-level adjustment" do
          expect(order.adjustments.length).to eq(1)
          expect(order.total).to eq(31.98)
          expect(order.item_total).to eq(39.98)
          # This is wrong! But order level adjustments can't work any other way
          expect(order.item_total_before_tax).to eq(39.98)
          expect(order.line_items.flat_map(&:adjustments)).to be_empty
        end
      end

      context "with an line item level action" do
        let(:calculator) { Spree::Calculator::PercentOnLineItem.new(preferred_percent: 20) }
        let(:action) { Spree::Promotion::Actions::CreateItemAdjustments.new(calculator: calculator) }

        it "creates one order-level adjustment" do
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(31.98)
          expect(order.item_total).to eq(39.98)
          expect(order.item_total_before_tax).to eq(31.98)
          expect(order.line_items.flat_map(&:adjustments).length).to eq(2)
        end
      end
    end

    context "with a line-item level rule" do
      let(:rule) { SolidusFriendlyPromotions::Rules::LineItemProduct.new(products: [shirt]) }

      context "with an order level action" do
        let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 20) }
        let(:action) { Spree::Promotion::Actions::CreateAdjustment.new(calculator: calculator) }

        it "creates one order-level adjustment" do
          # Whoops - this works because line item level rules don't affect order-level actions :(
          expect(order.adjustments.length).to eq(1)
          expect(order.total).to eq(31.98)
          expect(order.item_total).to eq(39.98)
          # This is wrong! But order level adjustments can't work any other way
          expect(order.item_total_before_tax).to eq(39.98)
          expect(order.line_items.flat_map(&:adjustments)).to be_empty
        end
      end

      context "with an line item level action" do
        let(:calculator) { Spree::Calculator::PercentOnLineItem.new(preferred_percent: 20) }
        let(:action) { Spree::Promotion::Actions::CreateItemAdjustments.new(calculator: calculator) }

        it "creates one line item level adjustment" do
          pending
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(35.98)
          expect(order.item_total).to eq(39.98)
          expect(order.item_total_before_tax).to eq(35.98)
          expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
        end
      end
    end
  end
end
