# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Calculators::FlatRate, type: :model do
  subject { calculator.compute(discountable) }

  let(:order) { mock_model(Spree::Order, currency: order_currency) }
  let(:calculator) do
    described_class.new(
      preferred_amount: preferred_amount,
      preferred_currency: preferred_currency
    )
  end

  it_behaves_like "a promotion calculator"

  context "compute_line_item" do
    let(:discountable) { mock_model(Spree::LineItem, order: order) }

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
    let(:discountable) { mock_model(Spree::Shipment, order: order) }
    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end

  context "compute_shipping_rate" do
    let(:discountable) { mock_model(Spree::ShippingRate, order: order) }
    describe "when preferred currency matches order" do
      let(:preferred_currency) { "GBP" }
      let(:order_currency) { "GBP" }
      let(:preferred_amount) { 25 }

      it { is_expected.to eq(25.0) }
    end
  end
end
