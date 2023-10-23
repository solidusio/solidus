# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::LineItemProduct, type: :model do
  let(:rule) { described_class.new(rule_options) }
  let(:rule_options) { {} }

  describe "#eligible?(line_item)" do
    subject { rule.eligible?(line_item, {}) }

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

      it "has no error message" do
        subject
        expect(rule.eligibility_errors.full_messages).to be_empty
      end
    end

    context "for product not in rule" do
      let(:line_item) { other_line_item }

      it { is_expected.to be_falsey }

      it "has the right error message" do
        subject
        expect(rule.eligibility_errors.full_messages.first).to eq(
          "You need to add an applicable product before applying this coupon code."
        )
      end
    end

    context "if match policy is inverse" do
      let(:rule_options) { super().merge(preferred_match_policy: "exclude") }

      context "for product in rule" do
        let(:line_item) { rule_line_item }

        it { is_expected.to be_falsey }

        it "has the right error message" do
          subject
          expect(rule.eligibility_errors.full_messages.first).to eq(
            "Your cart contains a product that prevents this coupon code from being applied."
          )
        end
      end

      context "for product not in rule" do
        let(:line_item) { other_line_item }

        it { is_expected.to be_truthy }

        it "has no error message" do
          subject
          expect(rule.eligibility_errors.full_messages).to be_empty
        end
      end
    end
  end
end
