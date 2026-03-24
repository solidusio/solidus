# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ProductAdvertiser do
  subject do
    described_class.new(product:, order:).call
  end

  let(:product) { create(:product) }
  let(:order) { create(:order) }
  let(:pricing_options) { Spree::Config.pricing_options_class.new }
  let(:benefit) do
    SolidusPromotions::Benefits::AdvertisePrice.new(
      calculator: SolidusPromotions::Calculators::Percent.new(preferred_percent: 5),
      conditions:
    )
  end

  let(:conditions) { [] }

  let!(:promotion) do
    create(
      :solidus_promotion,
      benefits: [benefit],
      apply_automatically: true
    )
  end

  it "applies a discount to the product's price" do
    subject
    # 5% off 19.99 ≃ 18.99
    expect(product.master.prices.first.discounted_amount).to eq(18.99)
    expect(product.master.prices.first.discounts.map(&:label)).to include("Promotion (Because we like you)")
  end

  it "keeps the discounts when selected through price_for_options" do
    price = product.master.price_for_options(pricing_options)
    expect { subject }.to change { price.discounted_amount }.by(-1)
  end

  context "if condition excludes product" do
    let(:conditions) { [condition] }
    let(:condition) do
      SolidusPromotions::Conditions::PriceProduct.new(products: [product], preferred_match_policy: :exclude)
    end

    it "will not apply the discount" do
      price = product.master.price_for_options(pricing_options)
      expect { subject }.not_to change { price.discounted_amount }
    end
  end

  context "when the product has variants" do
    let(:variant) { create(:variant) }
    let(:product) { variant.product }

    it "applies a discount to the variant's prices" do
      expect { subject }.to change { product.variants.first.price_for_options(pricing_options).discounted_amount }
    end
  end
end
