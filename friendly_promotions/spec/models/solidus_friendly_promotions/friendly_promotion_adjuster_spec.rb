# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::FriendlyPromotionAdjuster, type: :model do
  subject(:discounter) { described_class.new(order) }

  let(:line_item) { create(:line_item) }
  let(:order) { line_item.order }
  let(:promotion) { create(:friendly_promotion, apply_automatically: true) }
  let(:calculator) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 10) }

  context "adjusting line items" do
    let(:action) do
      SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: promotion, conditions: conditions, calculator: calculator)
    end
    let(:adjustable) { line_item }

    subject do
      action
      discounter.call
    end

    context "promotion with conditionless action" do
      let(:conditions) { [] }

      context "creates the adjustment" do
        it "creates the adjustment" do
          expect {
            subject
          }.to change { adjustable.adjustments.length }.by(1)
        end

        it "does not keep the current discounts" do
          subject
          expect(adjustable.current_discounts).to be_empty
        end

        context "if order is complete but not shipped" do
          let(:line_item) { order.line_items.first }
          let(:order) { create(:order_ready_to_ship) }

          it "creates the adjustment" do
            expect {
              subject
              order.save
            }.to change { adjustable.reload.adjustments.length }.by(1)
          end

          context "but the preference to recalculate complete orders is set to false" do
            around do |example|
              SolidusFriendlyPromotions.config.recalculate_complete_orders = false
              example.run
              SolidusFriendlyPromotions.config.recalculate_complete_orders = true
            end

            it "will not create the adjustment" do
              expect {
                subject
                order.save
              }.not_to change { adjustable.reload.adjustments.length }
            end
          end
        end
      end

      context "with a calculator that returns zero" do
        let(:calculator) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 0) }
        it " will not create the adjustment" do
          expect {
            subject
          }.not_to change { adjustable.adjustments.length }
        end
      end

      context "for a non-sale promotion" do
        let(:promotion) { create(:friendly_promotion, apply_automatically: false) }

        it "doesn't connect the promotion to the order" do
          expect {
            subject
          }.to change { order.promotions.length }.by(0)
        end

        it "doesn't create an adjustment" do
          expect {
            subject
          }.to change { adjustable.adjustments.length }.by(0)
        end

        context "for an line item that has an adjustment from the old promotion system" do
          let(:old_promotion_action) { create(:promotion, :with_adjustable_action, apply_automatically: false).actions.first }
          let!(:adjustment) { create(:adjustment, source: old_promotion_action, adjustable: line_item) }

          it "removes the old adjustment from the line item" do
            adjustable.reload
            expect {
              subject
            }.to change { adjustable.reload.adjustments.length }.by(-1)
          end
        end
      end
    end

    context "promotion includes item involved" do
      let(:conditions) { [condition] }
      let(:condition) do
        SolidusFriendlyPromotions::Conditions::Product.create(products: [line_item.product])
      end

      context "creates the adjustment" do
        it "creates the adjustment" do
          expect {
            subject
          }.to change { adjustable.adjustments.length }.by(1)
        end
      end
    end

    context "promotion has item total condition" do
      let(:conditions) { [condition] }
      let(:condition) do
        SolidusFriendlyPromotions::Conditions::ItemTotal.create(
          preferred_operator: "gt",
          preferred_amount: 50
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
            subject
          }.to change { adjustable.adjustments.length }.by(1)
        end
      end
    end
  end

  context "adjusting shipping rates" do
    let(:promotion) { create(:friendly_promotion, actions: [shipment_action], apply_automatically: true) }
    let(:shipment_action) { SolidusFriendlyPromotions::Actions::AdjustShipment.new(calculator: fifty_percent) }
    let(:fifty_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 50) }
    let(:order) { create(:order_with_line_items) }

    subject do
      promotion
      discounter.call
    end

    it "creates shipping rate discounts" do
      expect { subject }.to change { SolidusFriendlyPromotions::ShippingRateDiscount.count }
    end

    context "if the promo is eligible but the calculcator returns 0" do
      let(:shipment_action) { SolidusFriendlyPromotions::Actions::AdjustShipment.new(calculator: zero_percent) }
      let(:zero_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "will not create an adjustment on the shipping rate" do
        expect do
          subject
        end.not_to change { order.shipments.first.shipping_rates.first.discounts.count }
      end
    end
  end

  context "adjusting shipments" do
    let(:promotion) { create(:friendly_promotion, actions: [shipment_action], apply_automatically: true) }
    let(:shipment_action) { SolidusFriendlyPromotions::Actions::AdjustShipment.new(calculator: fifty_percent) }
    let(:fifty_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 50) }
    let(:order) { create(:order_with_line_items) }

    it "creates an adjustment on the shipment" do
      expect do
        promotion
        subject.call
      end.to change { order.shipments.first.adjustments.count }
    end

    context "if the promo is eligible but the calculcator returns 0" do
      let(:shipment_action) { SolidusFriendlyPromotions::Actions::AdjustShipment.new(calculator: zero_percent) }
      let(:zero_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "will not create an adjustment on the shipment" do
        expect do
          promotion
          subject.call
        end.not_to change { order.shipments.first.adjustments.count }
      end
    end
  end
end
