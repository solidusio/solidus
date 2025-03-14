# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster, type: :model do
  subject(:discounter) { described_class.new(order) }

  let(:line_item) { create(:line_item) }
  let(:order) { line_item.order }
  let(:promotion) { create(:solidus_promotion, apply_automatically: true) }
  let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 10) }

  context "adding discounted line items" do
    let(:variant) { create(:variant, price: 100) }
    let(:benefit) do
      SolidusPromotions::Benefits::CreateDiscountedItem.create(
        promotion: promotion,
        calculator: calculator,
        preferences: { variant_id: variant.id }
      )
    end
    let(:adjustable) { order }

    subject do
      benefit
      discounter.call
    end

    it "creates a line item of the given variant with a discount adjustment corresponding to the calculator" do
      expect {
        subject
      }.to change { order.line_items.count }.by(1)

      expect(order.line_items.last.variant).to eq(variant)
      expect(order.line_items.last.adjustments.promotion.first&.amount).to eq(-10)
    end
  end

  context "adjusting line items" do
    let(:benefit) do
      SolidusPromotions::Benefits::AdjustLineItem.create(promotion: promotion, calculator: calculator)
    end
    let(:adjustable) { line_item }

    subject do
      benefit
      discounter.call
    end

    context "promotion with conditionless benefit" do
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
              SolidusPromotions.config.recalculate_complete_orders = false
              example.run
              SolidusPromotions.config.recalculate_complete_orders = true
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
        let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 0) }
        it " will not create the adjustment" do
          expect {
            subject
          }.not_to change { adjustable.adjustments.length }
        end
      end

      context "for a non-sale promotion" do
        let(:promotion) { create(:solidus_promotion, apply_automatically: false) }

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
          let(:old_promotion_benefit) { create(:promotion, :with_adjustable_action, apply_automatically: false).actions.first }
          let!(:adjustment) { create(:adjustment, source: old_promotion_benefit, adjustable: line_item) }

          it "marks the old adjustment for destruction" do
            adjustable.reload
            expect {
              subject
            }.to change { adjustable.adjustments.first.marked_for_destruction? }
              .from(false).to(true)
          end
        end
      end
    end

    context "promotion includes item involved" do
      before do
        benefit.conditions.create(type: "SolidusPromotions::Conditions::Product", products: [line_item.product])
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
      before do
        benefit.conditions.create!(
          type: "SolidusPromotions::Conditions::ItemTotal",
          preferred_operator: "gt",
          preferred_amount: 50
        )
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
    let(:promotion) { create(:solidus_promotion, benefits: [shipment_benefit], apply_automatically: true) }
    let(:shipment_benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: fifty_percent) }
    let(:fifty_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 50) }
    let(:order) { create(:order_with_line_items) }

    subject do
      promotion
      discounter.call
    end

    it "creates shipping rate discounts" do
      expect { subject }.to change { SolidusPromotions::ShippingRateDiscount.count }
    end

    context "if the promo is eligible but the calculcator returns 0" do
      let(:shipment_benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: zero_percent) }
      let(:zero_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "will not create an adjustment on the shipping rate" do
        expect do
          subject
        end.not_to change { order.shipments.first.shipping_rates.first.discounts.count }
      end
    end
  end

  context "adjusting shipments" do
    let(:promotion) { create(:solidus_promotion, benefits: [shipment_benefit], apply_automatically: true) }
    let(:shipment_benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: fifty_percent) }
    let(:fifty_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 50) }
    let(:order) { create(:order_with_line_items) }

    it "creates an adjustment on the shipment" do
      expect do
        promotion
        subject.call
      end.to change { order.shipments.first.adjustments.count }
    end

    context "if the promo is eligible but the calculcator returns 0" do
      let(:shipment_benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: zero_percent) }
      let(:zero_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "will not create an adjustment on the shipment" do
        expect do
          promotion
          subject.call
        end.not_to change { order.shipments.first.adjustments.count }
      end
    end
  end
end
