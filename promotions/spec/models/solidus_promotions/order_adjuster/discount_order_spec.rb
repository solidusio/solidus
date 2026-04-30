# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster::DiscountOrder do
  context "shipped orders" do
    let(:promotions) { [] }
    let(:order) { create(:order, shipment_state: "shipped") }

    subject { described_class.new(order, promotions).call }

    it "returns the order unmodified" do
      expect(subject).to eq(order)
      expect(order.changes).to be_empty
    end
  end

  describe "discounting orders" do
    let(:shirt) { create(:product, name: "Shirt") }
    let(:order) { create(:order_with_line_items, line_items_attributes: [{variant: shirt.master, quantity: 1}]) }
    let!(:promotion) { create(:solidus_promotion, :with_free_shipping, name: "20% off Shirts", apply_automatically: true) }
    let(:promotions) { [promotion] }
    let(:discounter) { described_class.new(order, promotions) }

    subject { discounter.call }

    before do
      order.shipments.first.shipping_rates.first.update!(cost: nil)
    end

    it "does not blow up if the shipping rate cost is nil" do
      expect { subject }.not_to raise_exception
    end
  end
end
