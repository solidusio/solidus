# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ProductDiscounter do
  subject do
    described_class.new(product:, order:, pricing_options:).call
  end

  let(:product) { create(:product) }
  let(:order) { create(:order) }
  let(:pricing_options) do
    Spree::Variant::PricingOptions.new
  end

  let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, promotion_benefit_class: SolidusPromotions::Benefits::AdjustPrice, apply_automatically: true) }

  it "applies a discount to the product's price" do
    expect { product.discounted_price }.to raise_exception(SolidusPromotions::VariantPatch::VariantNotDiscounted)
    subject
    # Standard benefit calculator is a flat 10 USD off
    expect(product.discounted_price).to eq(9.99)
    expect(product.price_discounts.map(&:label)).to include("Promotion (Because we like you)")
  end
end
