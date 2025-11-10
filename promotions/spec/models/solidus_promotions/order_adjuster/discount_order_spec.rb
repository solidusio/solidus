# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster::DiscountOrder do
  context "shipped orders" do
    let(:promotions) { [] }
    let(:order) { create(:order, shipment_state: "shipped") }

    subject { described_class.new(order, promotions).call }

    it "returns the order unmodified" do
      expect(order).not_to receive(:reset_current_discounts)
      expect(subject).to eq(order)
    end
  end

  describe "discounting orders" do
    let(:shirt) { create(:product, name: "Shirt") }
    let(:order) { create(:order_with_line_items, line_items_attributes: [{ variant: shirt.master, quantity: 1 }]) }
    let!(:promotion) { create(:solidus_promotion, :with_free_shipping, name: "20% off Shirts", apply_automatically: true) }
    let(:promotions) { [promotion] }
    let(:discounter) { described_class.new(order, promotions) }

    subject { discounter.call }

    before do
      order.shipments.first.shipping_rates.first.update!(cost: nil)
    end

    it "does not blow up if the shipping rate cost is nil" do
      expect { subject }.not_to raise_exception
    end
  end

  describe "collecting eligibility results in a dry run" do
    let(:shirt) { create(:product, name: "Shirt") }
    let(:order) { create(:order_with_line_items, line_items_attributes: [{ variant: shirt.master, quantity: 1 }]) }
    let(:conditions) { [product_condition] }
    let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, conditions: conditions, name: "20% off Shirts", apply_automatically: true) }
    let(:product_condition) { SolidusPromotions::Conditions::OrderProduct.new(products: [shirt]) }
    let(:promotions) { [promotion] }
    let(:discounter) { described_class.new(order, promotions, dry_run: true) }

    subject { discounter.call }

    it "will collect eligibility results" do
      subject

      expect(promotion.eligibility_results.first.success).to be true
      expect(promotion.eligibility_results.first.code).to be nil
      expect(promotion.eligibility_results.first.condition).to eq(product_condition)
      expect(promotion.eligibility_results.first.message).to be nil
      expect(promotion.eligibility_results.first.item).to eq(order)
    end

    it "can tell us about success" do
      subject
      expect(promotion.eligibility_results.success?).to be true
    end

    context "with two conditions" do
      let(:conditions) { [product_condition, item_total_condition] }
      let(:item_total_condition) { SolidusPromotions::Conditions::ItemTotal.new(preferred_amount: 2000) }

      it "will collect eligibility results" do
        subject

        expect(promotion.eligibility_results.first.success).to be true
        expect(promotion.eligibility_results.first.code).to be nil
        expect(promotion.eligibility_results.first.condition).to eq(product_condition)
        expect(promotion.eligibility_results.first.message).to be nil
        expect(promotion.eligibility_results.first.item).to eq(order)
        expect(promotion.eligibility_results.last.success).to be false
        expect(promotion.eligibility_results.last.condition).to eq(item_total_condition)
        expect(promotion.eligibility_results.last.code).to eq :item_total_less_than_or_equal
        expect(promotion.eligibility_results.last.message).to eq "This coupon code can't be applied to orders less than or equal to $2,000.00."
        expect(promotion.eligibility_results.last.item).to eq(order)
      end

      it "can tell us about success" do
        subject
        expect(promotion.eligibility_results.success?).to be false
      end

      it "has errors for this promo" do
        subject
        expect(promotion.eligibility_results.error_messages).to eq([
          "This coupon code can't be applied to orders less than or equal to $2,000.00."
        ])
      end
    end

    context "with an order with multiple line items and an item-level condition" do
      let(:pants) { create(:product, name: "Pants") }
      let(:order) do
        create(
          :order_with_line_items,
          line_items_attributes: [{ variant: shirt.master, quantity: 1 }, { variant: pants.master, quantity: 1 }]
        )
      end

      let(:shirt_product_condition) { SolidusPromotions::Conditions::LineItemProduct.new(products: [shirt]) }
      let(:conditions) { [shirt_product_condition] }

      it "can tell us about success" do
        subject
        # This is successful, because one of the line item conditions matches
        expect(promotion.eligibility_results.success?).to be true
      end

      it "has no errors for this promo" do
        subject
        expect(promotion.eligibility_results.error_messages).to be_empty
      end

      context "with a second line item level condition" do
        let(:hats) { create(:taxon, name: "Hats", products: [hat]) }
        let(:hat) { create(:product) }
        let(:hat_product_condition) { SolidusPromotions::Conditions::LineItemTaxon.new(taxons: [hats]) }
        let(:conditions) { [shirt_product_condition, hat_product_condition] }

        it "can tell us about success" do
          subject
          expect(promotion.eligibility_results.success?).to be false
        end

        it "has errors for this promo" do
          subject
          expect(promotion.eligibility_results.error_messages).to eq([
            "This coupon code could not be applied to the cart at this time."
          ])
        end
      end
    end

    context "when the order must not contain a shirt" do
      let(:no_shirt_condition) { SolidusPromotions::Conditions::OrderProduct.new(products: [shirt], preferred_match_policy: "none") }
      let(:conditions) { [no_shirt_condition] }

      it "can tell us about success" do
        subject
        # This is successful, because the order has a shirt
        expect(promotion.eligibility_results.success?).to be false
      end
    end

    context "where one benefit succeeds and another errors" do
      let(:usps) { create(:shipping_method) }
      let(:ups_ground) { create(:shipping_method) }
      let(:order) { create(:order_with_line_items, line_items_attributes: [{ variant: shirt.master, quantity: 1 }], shipping_method: ups_ground) }
      let(:product_condition) { SolidusPromotions::Conditions::OrderProduct.new(products: [shirt]) }
      let(:shipping_method_condition) { SolidusPromotions::Conditions::ShippingMethod.new(preferred_shipping_method_ids: [usps.id]) }
      let(:ten_off_items) { SolidusPromotions::Calculators::Percent.create!(preferred_percent: 10) }
      let(:ten_off_shipping) { SolidusPromotions::Calculators::Percent.create!(preferred_percent: 10) }
      let(:shipping_benefit) { SolidusPromotions::Benefits::AdjustShipment.new(calculator: ten_off_shipping) }
      let(:line_item_benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: ten_off_items) }
      let(:benefits) { [shipping_benefit, line_item_benefit] }
      let(:conditions) { [product_condition, shipping_method_condition] }
      let!(:promotion) { create(:solidus_promotion, benefits: benefits, name: "10% off Shirts and USPS Shipping", apply_automatically: true) }

      before do
        shipping_benefit.conditions << shipping_method_condition
        line_item_benefit.conditions << product_condition
      end

      it "can tell us about success" do
        subject
        expect(promotion.eligibility_results.success?).to be true
      end

      it "can tell us about errors" do
        subject
        expect(promotion.eligibility_results.error_messages).to eq(["This coupon code could not be applied to the cart at this time."])
      end
    end

    context "with no conditions" do
      let(:conditions) { [] }

      it "has no errors for this promo" do
        subject
        expect(promotion.eligibility_results.error_messages).to be_empty
      end
    end

    context "with an ineligible order-level condition" do
      let(:mug) { create(:product) }
      let(:order_condition) { SolidusPromotions::Conditions::NthOrder.new(preferred_nth_order: 2) }
      let(:line_item_condition) { SolidusPromotions::Conditions::LineItemProduct.new(products: [mug]) }
      let(:conditions) { [order_condition, line_item_condition] }

      it "can tell us about success" do
        subject
        expect(promotion.eligibility_results.success?).to be false
      end

      it "can tell us about all the errors" do
        subject
        expect(promotion.eligibility_results.error_messages).to eq(
          [
            "This coupon code could not be applied to the cart at this time.",
            "You need to add an applicable product before applying this coupon code."
          ]
        )
      end
    end
  end
end
