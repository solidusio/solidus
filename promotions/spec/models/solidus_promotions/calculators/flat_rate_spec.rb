# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::FlatRate, type: :model do
  subject { calculator.compute(discountable) }

  let(:order) { mock_model(Spree::Order, currency: order_currency) }
  let(:promotion) { build_stubbed(:solidus_promotion) }
  let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.new(promotion: promotion) }
  let(:calculator) do
    described_class.new(
      calculable: benefit,
      preferred_amount: preferred_amount,
      preferred_currency: preferred_currency
    )
  end

  it_behaves_like "a calculator with a description"

  context "compute_line_item" do
    let(:discountable) { mock_model(Spree::LineItem, order: order, discountable_amount: 100) }

    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end

    describe "when preferred currency does not match order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "USD" }
      let(:preferred_amount) { 25 }

      it { is_expected.to be_zero }
    end

    describe "when preferred currency does not match order" do
      let(:preferred_currency) { "" }
      let(:order_currency) { "USD" }
      let(:preferred_amount) { 25 }

      it { is_expected.to be_zero }
    end

    describe "when preferred currency and order currency use different casing" do
      let(:preferred_currency) { "gbP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end

  context "compute_shipment" do
    let(:discountable) { mock_model(Spree::Shipment, order: order, discountable_amount: 100) }
    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end

  context "compute_shipping_rate" do
    let(:discountable) { mock_model(Spree::ShippingRate, order: order, discountable_amount: 100) }
    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end

  describe "compute_price" do
    let(:preferred_currency) { "GBP" }
    let(:order_currency) { "GBP" }
    let(:preferred_amount) { 25 }

    let(:discountable) { mock_model(Spree::Price, amount: price_amount, variant: variant, discountable_amount: price_amount) }
    let(:variant) { build(:variant) }
    let(:price_amount) { 20 }
    let(:line_item) { Spree::LineItem.new(variant:, quantity:, price: 20) }
    let(:other_variant) { build(:variant) }
    let(:other_line_item) { Spree::LineItem.new(variant: other_variant) }
    let(:quantity) { 0 }
    let(:desired_quantity) { 1 }
    let(:order) { mock_model(Spree::Order, line_items: [line_item, other_line_item], currency: order_currency) }

    subject { calculator.compute(discountable, { order: order, quantity: desired_quantity }) }

    it { is_expected.to eq(20) }

    context "with discounted line item present" do
      let(:quantity) { 1 }
      it { is_expected.to eq(5) }
    end

    context "when desiring 2" do
      let(:desired_quantity) { 2 }
      it { is_expected.to eq(12.5) }
    end

    context "with discounted line item present that takes up the whole amount" do
      let(:quantity) { 2 }

      it { is_expected.to eq(0) }
    end

    context "with order currency different" do
      let(:quantity) { 1 }
      let(:order_currency) { "USD" }

      it { is_expected.to eq(0) }
    end

    context "if order is not given" do
      let(:order) { nil }
      let(:quantity) { 1 }

      it { is_expected.to eq(25) }
    end
  end
end
