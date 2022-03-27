# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Rules::LineItemProduct, type: :model do
  let(:rule) { described_class.new(rule_options) }
  let(:rule_options) { {} }

  context "#eligible?(line_item)" do
    let(:rule_line_item) { Spree::LineItem.new(product: rule_product) }
    let(:other_line_item) { Spree::LineItem.new(product: other_product) }

    let(:rule_options) { super().merge(products: [rule_product]) }
    let(:rule_product) { mock_model(Spree::Product) }
    let(:other_product) { mock_model(Spree::Product) }

    it "should be eligible if there are no products" do
      expect(rule).to be_eligible(rule_line_item)
    end

    subject { rule.eligible?(line_item, {}) }

    context "for product in rule" do
      let(:line_item) { rule_line_item }
      it { is_expected.to be_truthy }
    end

    context "for product not in rule" do
      let(:line_item) { other_line_item }
      it { is_expected.to be_falsey }
    end

    context "if match policy is inverse" do
      let(:rule_options) { super().merge(preferred_match_policy: "exclude") }

      context "for product in rule" do
        let(:line_item) { rule_line_item }
        it { is_expected.to be_falsey }
      end

      context "for product not in rule" do
        let(:line_item) { other_line_item }
        it { is_expected.to be_truthy }
      end
    end
  end
end
