# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::Product, type: :model do
  let(:condition_options) { {} }
  let(:condition) { described_class.new(condition_options) }

  it { is_expected.to have_many(:products) }

  describe "#applicable?" do
    let(:promotable) { Spree::Order.new }

    subject { condition.applicable?(promotable) }

    it { is_expected.to be true }

    context "with a line item" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be true }

      context "with line item applicable set to false" do
        let(:condition_options) { {preferred_line_item_applicable: false} }

        it { is_expected.to be false }
      end
    end

    context "with a shipment" do
      let(:promotable) { Spree::Shipment.new }

      it { is_expected.to be false }
    end
  end

  describe "#eligible?(order)" do
    let(:order) { create(:order) }
    let(:product_one) { create(:product) }
    let(:product_two) { create(:product) }
    let(:product_three) { create(:product) }
    let(:order_products) { [] }
    let(:eligible_products) { [] }

    before do
      order_products.each do |product|
        order.contents.add(product.master, 1)
      end

      condition.products = eligible_products
    end

    it "is eligible if there are no products" do
      expect(condition).to be_eligible(order)
    end

    context "with 'any' match policy" do
      let(:condition_options) { super().merge(preferred_match_policy: "any") }
      let(:order_products) { [product_one, product_two] }
      let(:eligible_products) { [product_two, product_three] }

      it "is eligible if any of the products is in eligible products" do
        expect(condition).to be_eligible(order)
      end

      context "when none of the products are eligible products" do
        let(:order_products) { [product_one] }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first)
            .to eq "You need to add an applicable product before applying this coupon code."
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :no_applicable_products
        end
      end
    end

    context "with 'all' match policy" do
      let(:condition_options) { super().merge(preferred_match_policy: "all") }
      let(:order_products) { [product_three, product_two, product_one] }
      let(:eligible_products) { [product_two, product_three] }

      it "is eligible if all of the eligible products are ordered" do
        expect(condition).to be_eligible(order)
      end

      context "when any of the eligible products is not ordered" do
        let(:order_products) { [product_one, product_two] }
        let(:eligible_products) { [product_one, product_two, product_three] }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first).to eq(
            "This coupon code can't be applied because you don't have all of the necessary products in your cart."
          )
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :missing_product
        end
      end
    end

    context "with 'none' match policy" do
      let(:condition_options) { super().merge(preferred_match_policy: "none") }
      let(:order_products) { [product_one] }
      let(:eligible_products) { [product_two, product_three] }

      it "is eligible if none of the order's products are in eligible products" do
        expect(condition).to be_eligible(order)
      end

      context "when any of the order's products are in eligible products" do
        let(:order_products) { [product_one, product_two] }
        let(:eligible_products) { [product_two, product_three] }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first)
            .to eq "Your cart contains a product that prevents this coupon code from being applied."
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_product
        end
      end
    end

    context "with 'only' match policy" do
      let(:condition_options) { super().merge(preferred_match_policy: "only") }
      let(:order_products) { [product_one] }
      let(:eligible_products) { [product_one] }

      it "is eligible if all of the order's products are in eligible products" do
        expect(condition).to be_eligible(order)
      end

      context "if none of the order's products are in eligible products" do
        let(:eligible_products) { [product_two, product_three] }

        it "is not eligible" do
          expect(condition).not_to be_eligible(order)
        end
      end

      context "when any of the order's products are in eligible products" do
        let(:order_products) { [product_one, product_two] }
        let(:eligible_products) { [product_two, product_three] }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first)
            .to eq "Your cart contains a product that prevents this coupon code from being applied."
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_product
        end
      end
    end
  end

  describe "#eligible?(line_item)" do
    subject { condition.eligible?(line_item) }

    let(:condition_line_item) { Spree::LineItem.new(product: condition_product) }
    let(:other_line_item) { Spree::LineItem.new(product: other_product) }

    let(:condition_options) { super().merge(products: [condition_product]) }
    let(:condition_product) { mock_model(Spree::Product) }
    let(:other_product) { mock_model(Spree::Product) }

    it "is eligible if there are no products" do
      expect(condition).to be_eligible(condition_line_item)
    end

    context "for product in condition" do
      let(:line_item) { condition_line_item }

      it { is_expected.to be_truthy }
    end

    context "for product not in condition" do
      let(:line_item) { other_line_item }

      it { is_expected.to be_falsey }
    end
  end
end
