# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Calculators::TieredPercentOnEligibleItemQuantity do
  let(:order) do
    create(:order_with_line_items, line_items_attributes: [first_item_attrs, second_item_attrs, third_item_attrs])
  end

  let(:first_item_attrs) { {variant: shirt, quantity: 2, price: 50} }
  let(:second_item_attrs) { {variant: pants, quantity: 3} }
  let(:third_item_attrs) { {variant: mug, quantity: 1} }

  let(:shirt) { create(:variant) }
  let(:pants) { create(:variant) }
  let(:mug) { create(:variant) }

  let(:clothes) { create(:taxon, products: [shirt.product, pants.product]) }

  let(:promotion) { create(:solidus_promotion, name: "10 Percent on 5 apparel, 15 percent on 10", benefits: [benefit]) }
  let(:clothes_only) { SolidusPromotions::Conditions::Taxon.new(taxons: [clothes]) }
  let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(calculator: calculator, conditions: [clothes_only]) }
  let(:calculator) { described_class.new(preferred_base_percent: 10, preferred_tiers: {10 => 15.0}) }

  let(:line_item) { order.line_items.detect { _1.variant == shirt } }

  subject { promotion.benefits.first.calculator.compute(line_item) }

  # 2 Shirts at 50, 100 USD. 10 % == 10
  it { is_expected.to eq(10) }

  context "if we have 12" do
    let(:first_item_attrs) { {variant: shirt, quantity: 7, price: 50} }
    let(:second_item_attrs) { {variant: pants, quantity: 5} }

    # 7 Shirts at 50, 350 USD, 15 % == 52.5
    it { is_expected.to eq(52.5) }
  end

  context "if the order's currency is different" do
    before do
      order.currency = "GBP"
      order.save!
    end

    it { is_expected.to eq(0) }
  end
end
