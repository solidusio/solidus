# frozen_string_literal: true

require "rails_helper"
require "solidus_promotions/promotion_map"
require "solidus_promotions/promotion_migrator"

RSpec.describe "Promotion System" do
  context "A promotion that creates line item adjustments" do
    let(:shirt) { create(:product, name: "Shirt") }
    let(:pants) { create(:product, name: "Pants") }
    let!(:promotion) { create(:solidus_promotion, name: "20% off Shirts", benefits: [benefit], apply_automatically: true) }
    let(:order) { create(:order) }

    before do
      benefit.conditions << condition
      order.contents.add(shirt.master, 1)
      order.contents.add(pants.master, 1)
    end

    context "with an order-level condition" do
      let(:condition) { SolidusPromotions::Conditions::OrderProduct.new(products: [shirt]) }

      context "with an line item level benefit" do
        let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
        let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: calculator) }

        it "creates one line item level adjustment" do
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(31.98)
          expect(order.item_total).to eq(39.98)
          expect(order.item_total_before_tax).to eq(31.98)
          expect(order.line_items.flat_map(&:adjustments).length).to eq(2)
        end
      end

      context "with an automation" do
        let(:goodie) { create(:variant, price: 4) }
        let(:benefit) { SolidusPromotions::Benefits::CreateDiscountedItem.new(preferred_variant_id: goodie.id, calculator: hundred_percent) }
        let(:hundred_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 100) }
        let(:condition) { SolidusPromotions::Conditions::Product.new(products: [shirt]) }

        it "creates a new discounted line item" do
          expect(order.adjustments).to be_empty
          expect(order.line_items.count).to eq(3)
          # 19.99 * 2
          expect(order.total).to eq(39.98)
          # 19.99 * 2 + 4 * 1
          expect(order.item_total).to eq(43.98)
          expect(order.item_total_before_tax).to eq(39.98)
          expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
        end

        context "when a second base item is added" do
          before do
            order.contents.add(shirt.master)
          end

          it "creates a new discounted line item" do
            expect(order.adjustments).to be_empty
            expect(order.line_items.count).to eq(3)
            # 19.99 * 3
            expect(order.total).to eq(59.97)
            expect(order.item_total).to eq(67.97)
            expect(order.item_total_before_tax).to eq(59.97)
            expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
          end
        end

        context "when the goodie becomes unavailable" do
          before do
            order.contents.remove(shirt.master)
          end

          it "removes the discounted line item" do
            expect(order.adjustments).to be_empty
            expect(order.line_items.length).to eq(1)
            expect(order.promo_total).to eq(0)
            expect(order.total).to eq(19.99)
            expect(order.item_total).to eq(19.99)
            expect(order.item_total_before_tax).to eq(19.99)
            expect(order.line_items.flat_map(&:adjustments).length).to eq(0)
          end
        end

        context "with a line-item level promotion in the lane before it" do
          let!(:other_promotion) { create(:solidus_promotion, :with_adjustable_benefit, lane: :pre, apply_automatically: true) }

          it "creates a new discounted line item" do
            order.recalculate
            expect(order.adjustments).to be_empty
            expect(order.line_items.count).to eq(3)
            expect(order.total).to eq(19.98)
            expect(order.item_total).to eq(43.98)
            expect(order.item_total_before_tax).to eq(19.98)
            expect(order.line_items.flat_map(&:adjustments).length).to eq(3)
            expect(order.line_items.detect { |line_item| line_item.managed_by_order_benefit == benefit }.adjustments.length).to eq(1)
            expect(order.line_items.detect { |line_item| line_item.managed_by_order_benefit == benefit }.adjustments.first.amount).to eq(-4)
          end
        end
      end
    end

    context "with a line-item level condition" do
      let(:condition) { SolidusPromotions::Conditions::LineItemProduct.new(products: [shirt]) }

      context "with an line item level benefit" do
        let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
        let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: calculator) }

        it "creates one line item level adjustment" do
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(35.98)
          expect(order.item_total).to eq(39.98)
          expect(order.item_total_before_tax).to eq(35.98)
          expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
        end
      end
    end
  end

  context "with two promotions that should stack" do
    let(:shirt) { create(:product, name: "Shirt", price: 30) }
    let(:pants) { create(:product, name: "Pants", price: 40) }
    let(:discounted_item_total_condition_amount) { 60 }
    let(:discounted_item_total_condition) do
      SolidusPromotions::Conditions::DiscountedItemTotal.new(preferred_amount: discounted_item_total_condition_amount)
    end
    let(:discounted_item_total_benefit) do
      SolidusPromotions::Benefits::AdjustLineItem.new(calculator: discounted_item_total_calculator, conditions: [discounted_item_total_condition])
    end
    let(:discounted_item_total_calculator) do
      SolidusPromotions::Calculators::DistributedAmount.new(preferred_amount: 10)
    end
    let!(:distributed_amount_promo) do
      create(
        :solidus_promotion,
        benefits: [discounted_item_total_benefit],
        apply_automatically: true,
        lane: :post
      )
    end

    let(:shirts_condition) { SolidusPromotions::Conditions::LineItemProduct.new(products: [shirt]) }
    let(:shirts_calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
    let(:shirts_benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: shirts_calculator, conditions: [shirts_condition]) }
    let!(:shirts_promotion) do
      create(
        :solidus_promotion,
        benefits: [shirts_benefit],
        name: "20% off shirts",
        apply_automatically: true
      )
    end
    let(:order) { create(:order) }

    before do
      order.contents.add(shirt.master, 1)
      order.contents.add(pants.master, 1)
    end

    it "does all the right things" do
      expect(order.adjustments).to be_empty
      # shirt: 30 USD - 20% = 24 USD
      # Remaining total: 64 USD
      # 10 USD distributed off: 54 USD
      expect(order.total).to eq(54.00)
      expect(order.item_total).to eq(70.00)
      expect(order.item_total_before_tax).to eq(54)
      expect(order.line_items.flat_map(&:adjustments).length).to eq(3)
    end

    context "if the post lane promotion is ineligible" do
      let(:discounted_item_total_condition_amount) { 68 }

      it "does all the right things" do
        expect(order.adjustments).to be_empty
        # shirt: 30 USD - 20% = 24 USD
        # Remaining total: 64 USD
        # The 10 off promotion does not apply because now the order total is below 68
        expect(order.total).to eq(64.00)
        expect(order.item_total).to eq(70.00)
        expect(order.item_total_before_tax).to eq(64)
        expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
      end
    end
  end

  context "with a migrated spree_promotion that is attached to the current order" do
    let(:shirt) { create(:variant) }
    let(:spree_promotion) { create(:promotion, :with_adjustable_action, code: true) }
    let(:order) { create(:order_with_line_items, line_items_attributes: [{ variant: shirt }]) }

    before do
      Spree::Config.promotions = SolidusLegacyPromotions::Configuration.new
      Spree::Config.order_contents_class = "Spree::OrderContents"
      SolidusPromotions.config.sync_order_promotions = true
      promotion_code = spree_promotion.codes.first
      order.order_promotions << Spree::OrderPromotion.new(
        promotion_code: promotion_code,
        promotion: spree_promotion
      )
      Spree::PromotionHandler::Cart.new(order).activate
      order.recalculate
      expect(order.line_items.first.adjustments.first.source).to eq(spree_promotion.promotion_actions.first)
      promotion_map = SolidusPromotions::PROMOTION_MAP
      SolidusPromotions::PromotionMigrator.new(promotion_map).call
      expect(SolidusPromotions::Promotion.count).to eq(1)

      Spree::Config.promotions = SolidusPromotions::Configuration.new
      Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
    end

    after do
      SolidusPromotions.config.sync_order_promotions = false
    end

    subject { order.recalculate }

    it "replaces existing adjustments with adjustments for the equivalent solidus promotion" do
      expect { subject }.not_to change { order.all_adjustments.count }
    end

    it "does not change the amount of any adjustments" do
      expect { subject }.not_to change { order.reload.all_adjustments.sum(&:amount) }
    end
  end

  context "with a shipment-level condition" do
    let!(:address) { create(:address) }
    let(:shipping_zone) { create(:global_zone) }
    let(:store) { create(:store) }
    let!(:ups_ground) { create(:shipping_method, zones: [shipping_zone], cost: 23) }
    let!(:dhl_saver) { create(:shipping_method, zones: [shipping_zone], cost: 37) }
    let(:variant) { create(:variant, price: 13) }
    let(:promotion) { create(:solidus_promotion, name: "20 percent off UPS Ground", apply_automatically: true) }
    let(:condition) { SolidusPromotions::Conditions::ShippingMethod.new(preferred_shipping_method_ids: [ups_ground.id]) }
    let(:order) { Spree::Order.create!(store: store) }

    before do
      promotion.benefits << benefit
      benefit.conditions << condition

      order.contents.add(variant, 1)
      order.ship_address = address
      order.bill_address = address

      order.create_proposed_shipments

      order.shipments.first.selected_shipping_rate_id = order.shipments.first.shipping_rates.detect do |r|
        r.shipping_method == shipping_method
      end.id

      order.recalculate
    end

    context "with a line item level benefit" do
      let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
      let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: calculator) }
      let(:shipping_method) { ups_ground }

      it "creates adjustments" do
        expect(order.adjustments).to be_empty
        expect(order.total).to eq(33.40)
        expect(order.item_total).to eq(13)
        expect(order.item_total_before_tax).to eq(10.40)
        expect(order.promo_total).to eq(-2.60)
        expect(order.line_items.flat_map(&:adjustments).length).to eq(1)
        expect(order.shipments.flat_map(&:adjustments)).to be_empty
        expect(order.shipments.flat_map(&:shipping_rates).flat_map(&:discounts)).to be_empty
      end
    end

    context "with a shipment level benefit" do
      let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
      let(:benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: calculator) }

      context "when the order is eligible" do
        let(:shipping_method) { ups_ground }

        it "creates adjustments" do
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(31.40)
          expect(order.item_total).to eq(13)
          expect(order.item_total_before_tax).to eq(13)
          expect(order.promo_total).to eq(-4.6)
          expect(order.line_items.flat_map(&:adjustments)).to be_empty
          expect(order.shipments.flat_map(&:adjustments)).not_to be_empty
          expect(order.shipments.flat_map(&:shipping_rates).flat_map(&:discounts)).not_to be_empty
        end
      end

      context "when the order is not eligible" do
        let(:shipping_method) { dhl_saver }

        it "creates no adjustments" do
          expect(order.adjustments).to be_empty
          expect(order.total).to eq(50)
          expect(order.item_total).to eq(13)
          expect(order.item_total_before_tax).to eq(13)
          expect(order.promo_total).to eq(0)
          expect(order.line_items.flat_map(&:adjustments)).to be_empty
          expect(order.shipments.flat_map(&:adjustments)).to be_empty
          expect(order.shipments.flat_map(&:shipping_rates).flat_map(&:discounts)).not_to be_empty
        end
      end
    end
  end
end
