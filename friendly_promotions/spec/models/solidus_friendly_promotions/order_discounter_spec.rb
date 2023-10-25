# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::OrderDiscounter, type: :model do
  subject { described_class.new(order) }

  let(:line_item) { create(:line_item) }
  let(:order) { line_item.order }
  let(:promotion) { create(:friendly_promotion, apply_automatically: true) }
  let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }

  context "adjusting line items" do
    let!(:action) do
      SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: promotion, calculator: calculator)
    end
    let(:adjustable) { line_item }

    context "promotion with no rules" do
      context "creates the adjustment" do
        it "creates the adjustment" do
          expect {
            subject.call
          }.to change { adjustable.adjustments.length }.by(1)
        end
      end

      context "for a non-sale promotion" do
        let(:promotion) { create(:friendly_promotion, apply_automatically: false) }

        it "doesn't connect the promotion to the order" do
          expect {
            subject.call
          }.to change { order.promotions.length }.by(0)
        end

        it "doesn't create an adjustment" do
          expect {
            subject.call
          }.to change { adjustable.adjustments.length }.by(0)
        end

        context "for an line item that has an adjustment from the old promotion system" do
          let(:old_promotion_action) { create(:promotion, :with_adjustable_action, apply_automatically: false).actions.first }
          let!(:adjustment) { create(:adjustment, source: old_promotion_action, adjustable: line_item) }

          it "removes the old adjustment from the line item" do
            adjustable.reload
            expect {
              subject.call
            }.to change { adjustable.reload.adjustments.length }.by(-1)
          end
        end
      end
    end

    context "promotion includes item involved" do
      let!(:rule) do
        SolidusFriendlyPromotions::Rules::Product.create(products: [line_item.product], promotion: promotion)
      end

      context "creates the adjustment" do
        it "creates the adjustment" do
          expect {
            subject.call
          }.to change { adjustable.adjustments.length }.by(1)
        end
      end
    end

    context "promotion has item total rule" do
      let!(:rule) do
        SolidusFriendlyPromotions::Rules::ItemTotal.create(
          preferred_operator: "gt",
          preferred_amount: 50,
          promotion: promotion
        )
      end

      before do
        # Makes the order eligible for this promotion
        order.item_total = 100
        order.save
      end

      context "creates the adjustment" do
        it "creates the adjustment" do
          expect {
            subject.call
          }.to change { adjustable.adjustments.length }.by(1)
        end
      end
    end
  end

  context "adjusting shipping rates" do
    let!(:promotion) { create(:friendly_promotion, actions: [shipment_action], apply_automatically: true) }
    let(:shipment_action) { SolidusFriendlyPromotions::Actions::AdjustShipment.new(calculator: fifty_percent) }
    let(:fifty_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 50) }
    let(:order) { create(:order_with_line_items) }

    it "creates shipping rate discounts" do
      expect { subject.call }.to change { SolidusFriendlyPromotions::ShippingRateDiscount.count }
    end
  end
end
