# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::LineItemProduct, type: :model do
  let(:condition) { described_class.new(condition_options) }
  let(:condition_options) { {} }

  describe "#level", :silence_deprecations do
    it "is line_item" do
      expect(condition.level).to eq(:line_item)
    end
  end

  describe "#eligible?(line_item)" do
    subject { condition.eligible?(line_item, {}) }

    let(:condition_line_item) { build(:line_item, product: condition_product) }
    let(:other_line_item) { build(:line_item) }

    let(:condition_options) { super().merge(products: [condition_product]) }
    let(:condition_product) { build(:product) }

    it "is eligible if there are no products" do
      expect(condition).to be_eligible(condition_line_item)
    end

    context "for product in condition" do
      let(:line_item) { condition_line_item }

      it { is_expected.to be_truthy }

      it "has no error message" do
        subject
        expect(condition.eligibility_errors.full_messages).to be_empty
      end
    end

    context "for product not in condition" do
      let(:line_item) { other_line_item }

      it { is_expected.to be_falsey }

      it "has the right error message" do
        subject
        expect(condition.eligibility_errors.full_messages.first).to eq(
          "You need to add an applicable product before applying this coupon code."
        )
      end
    end

    context "if match policy is inverse" do
      let(:condition_options) { super().merge(preferred_match_policy: "exclude") }

      context "for product in condition" do
        let(:line_item) { condition_line_item }

        it { is_expected.to be_falsey }

        it "has the right error message" do
          subject
          expect(condition.eligibility_errors.full_messages.first).to eq(
            "Your cart contains a product that prevents this coupon code from being applied."
          )
        end
      end

      context "for product not in condition" do
        let(:line_item) { other_line_item }

        it { is_expected.to be_truthy }

        it "has no error message" do
          subject
          expect(condition.eligibility_errors.full_messages).to be_empty
        end
      end
    end
  end
end
