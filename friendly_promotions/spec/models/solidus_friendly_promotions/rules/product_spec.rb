# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::Product, type: :model do
  it { is_expected.to have_many(:products) }

  let(:rule) { described_class.new(rule_options) }
  let(:rule_options) { {} }

  context "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "should be eligible if there are no products" do
      allow(rule).to receive_messages(eligible_products: [])
      expect(rule).to be_eligible(order)
    end

    before do
      3.times { |i| instance_variable_set("@product#{i}", mock_model(Spree::Product)) }
    end

    context "with 'any' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: "any") }

      it "should be eligible if any of the products is in eligible products" do
        allow(rule).to receive_messages(order_products: [@product1, @product2])
        allow(rule).to receive_messages(eligible_products: [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when none of the products are eligible products" do
        before do
          allow(rule).to receive_messages(order_products: [@product1])
          allow(rule).to receive_messages(eligible_products: [@product2, @product3])
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

      it "should be eligible if all of the eligible products are ordered" do
        allow(rule).to receive_messages(order_products: [@product3, @product2, @product1])
        allow(rule).to receive_messages(eligible_products: [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when any of the eligible products is not ordered" do
        before do
          allow(rule).to receive_messages(order_products: [@product1, @product2])
          allow(rule).to receive_messages(eligible_products: [@product1, @product2, @product3])
        end
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "This coupon code can't be applied because you don't have all of the necessary products in your cart."
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

      it "should be eligible if none of the order's products are in eligible products" do
        allow(rule).to receive_messages(order_products: [@product1])
        allow(rule).to receive_messages(eligible_products: [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when any of the order's products are in eligible products" do
        before do
          allow(rule).to receive_messages(order_products: [@product1, @product2])
          allow(rule).to receive_messages(eligible_products: [@product2, @product3])
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
        SolidusFriendlyPromotions::Rules::Product.create!(
          promotion: create(:friendly_promotion),
          products_rules: [
            SolidusFriendlyPromotions::ProductsRule.new(product: product)
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
end
