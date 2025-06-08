# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::Percent, type: :model do
  it_behaves_like "a calculator with a description"

  let(:currency) { "USD" }
  let(:order) { double(currency: currency) }

  context "compute_line_item" do
    let(:line_item) { mock_model("Spree::LineItem", discountable_amount: 100, order: order) }

    before { subject.preferred_percent = 15 }

    it "computes based on item price and quantity" do
      expect(subject.compute(line_item)).to eq 15
    end
  end

  describe "compute_shipment" do
    let(:shipment) { mock_model(Spree::Shipment, amount: 110, discountable_amount: 100, order: order) }

    before { subject.preferred_percent = 15 }

    it "computes based on item price and quantity" do
      expect(subject.compute(shipment)).to eq 15
    end
  end

  describe "compute_price" do
    let(:price) { mock_model(Spree::Price, amount: 110, discountable_amount: 100, currency: "USD") }

    before { subject.preferred_percent = 15 }

    it "computes based on item price and quantity" do
      expect(subject.compute(price, { order: order })).to eq 15
    end
  end
end
