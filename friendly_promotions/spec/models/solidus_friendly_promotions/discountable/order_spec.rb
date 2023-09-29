# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Discountable::Order do
  subject(:discountable_order) { described_class.new(spree_order) }

  let(:spree_order) { Spree::Order.new }

  describe "#line_items" do
    let(:spree_order) { create(:order_with_line_items) }
    subject(:line_items) { discountable_order.line_items }

    specify "are converted into Discountable Line Items" do
      line_items.each do |line_item|
        expect(line_item).to be_a(SolidusFriendlyPromotions::Discountable::LineItem)
      end
    end
  end

  describe "#shipments" do
    let(:spree_order) { create(:order_ready_to_ship) }
    subject(:shipments) { discountable_order.shipments }

    specify "are converted into Discountable Shipments" do
      shipments.each do |shipment|
        expect(shipment).to be_a(SolidusFriendlyPromotions::Discountable::Shipment)
      end
    end
  end

  describe "delegation" do
    let(:spree_order) { Spree::Order.new(email: "yoda@example.com") }

    it "forwards order attributes" do
      expect(subject.email).to eq("yoda@example.com")
    end
  end
end
