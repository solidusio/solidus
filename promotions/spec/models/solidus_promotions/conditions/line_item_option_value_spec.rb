# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::LineItemOptionValue do
  let!(:eligible_product) { create(:product) }
  let!(:eligible_variant) { create(:variant, product: eligible_product) }
  let!(:ineligible_variant) { create(:variant, product: eligible_product) }
  let!(:ineligible_product) { create(:product) }
  let!(:condition) do
    described_class.new(
      preferred_eligible_values: {
        eligible_product.id => eligible_variant.option_value_ids
      }
    )
  end

  subject { condition.eligible?(discountable) }

  context "with a Spree::LineItem" do
    let(:discountable) { build_stubbed(:line_item, variant: variant) }
    let(:variant) { eligible_variant }

    it { is_expected.to be true }

    context "if the variant is ineligible but with the same product" do
      let(:variant) { ineligible_variant }

      it { is_expected.to be false }
    end

    context "if the variant is ineligible because the product is wrong" do
      let(:variant) { ineligible_product.master }

      it { is_expected.to be false }
    end
  end

  context "with a Spree::Price" do
    let(:discountable) { build_stubbed(:price, variant: variant) }
    let(:variant) { eligible_variant }

    it { is_expected.to be true }

    context "if the variant is ineligible but with the same product" do
      let(:variant) { ineligible_variant }

      it { is_expected.to be false }
    end

    context "if the variant is ineligible because the product is wrong" do
      let(:variant) { ineligible_product.master }

      it { is_expected.to be false }
    end
  end
end
