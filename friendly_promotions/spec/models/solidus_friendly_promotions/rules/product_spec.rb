# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::Product, type: :model do
  let(:rule_options) { {} }
  let(:rule) { described_class.new(rule_options) }

  it { is_expected.to have_many(:products) }

  describe "#applicable?" do
    let(:promotable) { Spree::Order.new }

    subject { rule.applicable?(promotable) }

    it { is_expected.to be true }

    context "with a line item" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be true }

      context "with line item applicable set to false" do
        let(:rule_options) { {preferred_line_item_applicable: false} }

        it { is_expected.to be false }
      end
    end

    context "with a shipment" do
      let(:promotable) { Spree::Shipment.new }

      it { is_expected.to be false }
    end
  end

  describe "#eligible?(order)" do
    let(:order) { Spree::Order.new }
    let(:product_one) { build(:product) }
    let(:product_two) { build(:product) }
    let(:product_three) { build(:product) }

    it "is eligible if there are no products" do
      allow(rule).to receive_messages(eligible_products: [])
      expect(rule).to be_eligible(order)
    end

    context "with 'any' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: "any") }

      it "is eligible if any of the products is in eligible products" do
        allow(rule).to receive_messages(order_products: [product_one, product_two])
        allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        expect(rule).to be_eligible(order)
      end

      context "when none of the products are eligible products" do
        before do
          allow(rule).to receive_messages(order_products: [product_one])
          allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        end

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "You need to add an applicable product before applying this coupon code."
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :no_applicable_products
        end
      end
    end

    context "with 'all' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: "all") }

      it "is eligible if all of the eligible products are ordered" do
        allow(rule).to receive_messages(order_products: [product_three, product_two, product_one])
        allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        expect(rule).to be_eligible(order)
      end

      context "when any of the eligible products is not ordered" do
        before do
          allow(rule).to receive_messages(order_products: [product_one, product_two])
          allow(rule).to receive_messages(eligible_products: [product_one, product_two, product_three])
        end

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).to eq(
            "This coupon code can't be applied because you don't have all of the necessary products in your cart."
          )
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :missing_product
        end
      end
    end

    context "with 'none' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: "none") }

      it "is eligible if none of the order's products are in eligible products" do
        allow(rule).to receive_messages(order_products: [product_one])
        allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        expect(rule).to be_eligible(order)
      end

      context "when any of the order's products are in eligible products" do
        before do
          allow(rule).to receive_messages(order_products: [product_one, product_two])
          allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        end

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "Your cart contains a product that prevents this coupon code from being applied."
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_product
        end
      end
    end

    context "with 'only' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: "only") }

      it "is not eligible if none of the order's products are in eligible products" do
        allow(rule).to receive_messages(order_products: [product_one])
        allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        expect(rule).not_to be_eligible(order)
      end

      it "is eligible if all of the order's products are in eligible products" do
        allow(rule).to receive_messages(order_products: [product_one])
        allow(rule).to receive_messages(eligible_products: [product_one])
        expect(rule).to be_eligible(order)
      end

      context "when any of the order's products are in eligible products" do
        before do
          allow(rule).to receive_messages(order_products: [product_one, product_two])
          allow(rule).to receive_messages(eligible_products: [product_two, product_three])
        end

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "Your cart contains a product that prevents this coupon code from being applied."
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_product
        end
      end
    end

    context "with an invalid match policy" do
      let(:rule) do
        described_class.create!(
          promotion: create(:friendly_promotion),
          products_promotion_rules: [
            SolidusFriendlyPromotions::ProductsPromotionRule.new(product: product)
          ]
        ).tap do |rule|
          rule.preferred_match_policy = "invalid"
          rule.save!(validate: false)
        end
      end
      let(:product) { order.line_items.first!.product }
      let(:order) { create(:order_with_line_items, line_items_count: 1) }

      it "raises" do
        expect {
          rule.eligible?(order)
        }.to raise_error('unexpected match policy: "invalid"')
      end
    end
  end

  describe "#eligible?(line_item)" do
    subject { rule.eligible?(line_item) }

    let(:rule_line_item) { Spree::LineItem.new(product: rule_product) }
    let(:other_line_item) { Spree::LineItem.new(product: other_product) }

    let(:rule_options) { super().merge(products: [rule_product]) }
    let(:rule_product) { mock_model(Spree::Product) }
    let(:other_product) { mock_model(Spree::Product) }

    it "is eligible if there are no products" do
      expect(rule).to be_eligible(rule_line_item)
    end

    context "for product in rule" do
      let(:line_item) { rule_line_item }

      it { is_expected.to be_truthy }
    end

    context "for product not in rule" do
      let(:line_item) { other_line_item }

      it { is_expected.to be_falsey }
    end
  end
end
