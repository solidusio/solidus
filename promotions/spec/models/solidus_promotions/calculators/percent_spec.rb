# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Calculators::Percent, type: :model do
  context "compute" do
    let(:currency) { "USD" }
    let(:order) { Spree::Order.new(currency:) }
    let(:item) { Spree::LineItem.new(price: 9.99, quantity: 10, order: order) }
    let(:calculator) { described_class.new(preferred_percent: 15) }

    subject { calculator.compute(item) }

    it "computes based on item price and quantity" do
      expect(subject).to eq 14.99
    end

    context "with a shipment" do
      let(:item) { build(:shipment, cost: 29) }

      it { is_expected.to eq(4.35) }
    end

    context "with a shipping rate" do
      let(:item) { build(:shipping_rate, cost: 38) }

      it { is_expected.to eq(5.70) }
    end
  end

  it_behaves_like "a promotion calculator"
end
