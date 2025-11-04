# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::OrderProduct, type: :model do
  let(:condition_options) { {} }
  let(:condition) { described_class.new(condition_options) }

  it { is_expected.to have_many(:products) }

  describe "#applicable?" do
    let(:promotable) { Spree::Order.new }

    subject { condition.applicable?(promotable) }

    it { is_expected.to be true }

    context "with a line item" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
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

  describe "#to_partial_path" do
    subject { condition.to_partial_path }

    it { is_expected.to eq("solidus_promotions/admin/condition_fields/product") }
  end
end
