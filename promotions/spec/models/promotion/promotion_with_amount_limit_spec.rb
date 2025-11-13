# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Calculators::Percent, type: :model do
  describe "#compute_line_item" do
    let(:promotion) { create(:solidus_promotion, amount_limit:, apply_automatically: true) }
    let(:order) { create(:order) }

    let!(:taxon_electronics) { create(:taxon, name: "Electronics") }
    let!(:taxon_clothing) { create(:taxon, name: "Clothing") }

    let!(:product_laptop) { create(:product, price: 1000, taxons: [taxon_electronics]) }
    let!(:product_phone) { create(:product, price: 800, taxons: [taxon_electronics]) }
    let!(:product_shirt) { create(:product, price: 50, taxons: [taxon_clothing]) }
    let!(:product_jacket) { create(:product, price: 200, taxons: [taxon_clothing]) }

    let(:calculator_electronics) { described_class.new(preferred_percent: 20) }
    let(:calculator_clothing) { described_class.new(preferred_percent: 30) }

    let(:amount_limit) { 250 }
    let!(:benefit_electronics) do
      SolidusPromotions::Benefits::AdjustLineItem.create!(
        calculator: calculator_electronics,
        promotion: promotion,
        conditions: [SolidusPromotions::Conditions::LineItemTaxon.new(taxons: [taxon_electronics])]
      )
    end

    let!(:benefit_clothing) do
      SolidusPromotions::Benefits::AdjustLineItem.create!(
        calculator: calculator_clothing,
        promotion: promotion,
        conditions: [SolidusPromotions::Conditions::LineItemTaxon.new(taxons: [taxon_clothing])]
      )
    end

    context "when both benefits stay within cap" do
      before do
        order.contents.add(product_laptop.master, 1)
        order.contents.add(product_shirt.master, 1)
      end

      it "applies full discounts" do
        expect(order.promo_total).to eq(-215)
        expect(order.line_items.find_by(variant: product_laptop.master).adjustment_total).to eq(-200)
        expect(order.line_items.find_by(variant: product_shirt.master).adjustment_total).to eq(-15)
      end
    end

    context "when electronics benefit exhausts the cap" do
      before do
        order.contents.add(product_laptop.master, 1)
        order.contents.add(product_phone.master, 1)
        order.contents.add(product_shirt.master, 1)
      end

      it "caps electronics at $250 and gives clothing $0" do
        expect(order.promo_total).to eq(-250)
        laptop_discount = order.line_items.find_by(variant: product_laptop.master).adjustment_total
        phone_discount = order.line_items.find_by(variant: product_phone.master).adjustment_total
        expect(laptop_discount + phone_discount).to eq(-250)
        expect(order.line_items.find_by(variant: product_shirt.master).adjustment_total).to eq(0)
      end
    end

    context "when clothing benefit is applied first" do
      before do
        order.contents.add(product_shirt.master, 1)
        order.contents.add(product_jacket.master, 1)
        order.contents.add(product_phone.master, 1)
      end

      it "applies clothing discounts then remaining cap to electronics" do
        shirt_discount = order.line_items.find_by(variant: product_shirt.master).adjustment_total
        jacket_discount = order.line_items.find_by(variant: product_jacket.master).adjustment_total
        phone_discount = order.line_items.find_by(variant: product_phone.master).adjustment_total

        expect(shirt_discount).to eq(-15)
        expect(jacket_discount).to eq(-60)
        expect(phone_discount).to eq(-160)
        expect(order.promo_total).to eq(-235)
      end
    end

    context "when cap is exactly reached" do
      before do
        order.contents.add(product_laptop.master, 1)
        order.contents.add(product_shirt.master, 1)
        order.contents.add(product_jacket.master, 1)
      end

      it "stops at exactly $250" do
        expect(order.promo_total).to eq(-250)
      end
    end

    context "when cap is exceeded by both benefits combined" do
      before do
        order.contents.add(product_laptop.master, 2)
        order.contents.add(product_jacket.master, 2)
      end

      it "distributes cap proportionally" do
        expect(order.promo_total).to eq(-250)
      end
    end

    context "when one line item alone would exceed cap" do
      let!(:expensive_laptop) { create(:product, price: 2000, taxons: [taxon_electronics]) }

      before do
        order.contents.add(expensive_laptop.master, 1)
      end

      it "caps single item discount at $250" do
        expect(order.promo_total).to eq(-250)
      end
    end

    context "with small purchases" do
      before do
        order.contents.add(product_shirt.master, 2)
      end

      it "applies full discount when well below cap" do
        expect(order.promo_total).to eq(-30)
      end
    end

    context "when cap is zero" do
      let(:amount_limit) { 0 }

      before do
        order.contents.add(product_laptop.master, 1)
      end

      it "applies no discount" do
        expect(order.promo_total).to eq(0)
      end
    end

    context "when cap is negative" do
      let(:amount_limit) { -100 }

      before do
        order.contents.add(product_laptop.master, 1)
      end

      it "applies no discount" do
        expect(order.promo_total).to eq(0)
      end
    end

    context "when order has no applicable items" do
      let!(:product_other) { create(:product, price: 100) }

      before do
        order.contents.add(product_other.master, 1)
      end

      it "applies no discount" do
        expect(order.promo_total).to eq(0)
      end
    end

    context "with multiple quantities of same product" do
      before do
        order.contents.add(product_shirt.master, 5)
        order.contents.add(product_jacket.master, 2)
      end

      it "calculates correctly across quantities" do
        total_clothing = (50 * 5) + (200 * 2)
        expected_discount = total_clothing * 0.30
        expect(order.promo_total).to eq(-expected_discount)
      end
    end

    context "when benefits have different percentages approaching cap" do
      before do
        order.contents.add(product_phone.master, 1)
        order.contents.add(product_jacket.master, 3)
      end

      it "applies both benefits up to shared cap" do
        phone_full = 800 * 0.20
        jacket_full = 200 * 3 * 0.30
        total_full = phone_full + jacket_full

        expect(order.promo_total).to eq(-[total_full, 250].min)
      end
    end
  end
end
