# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionHandler::Page, type: :model do
  subject { described_class.new(order, path).activate }

  let(:order) { create(:order_with_line_items, line_items_count: 1) }
  let!(:promotion) { create(:friendly_promotion, :with_adjustable_benefit, name: "10% off", path: "10off") }
  let(:path) { "10off" }

  it "activates at the right path" do
    expect(order.line_item_adjustments.count).to eq(0)
    subject
    expect(order.line_item_adjustments.count).to eq(1)
  end

  context "when promotion is expired" do
    before do
      promotion.update(
        starts_at: 1.week.ago,
        expires_at: 1.day.ago
      )
    end

    it "is not activated" do
      expect(order.line_item_adjustments.count).to eq(0)
      subject
      expect(order.line_item_adjustments.count).to eq(0)
    end
  end

  context "with a wrong path" do
    let(:path) { "wrongpath" }
    it "does not activate at the wrong path" do
      expect(order.line_item_adjustments.count).to eq(0)
      subject
      expect(order.line_item_adjustments.count).to eq(0)
    end
  end

  context "when promotion is not eligible" do
    let(:impossible_condition) { SolidusFriendlyPromotions::Conditions::NthOrder.new(preferred_nth_order: 2) }
    before do
      promotion.benefits.first.conditions << impossible_condition
    end

    it "is not applied" do
      expect { subject }.not_to change { order.line_item_adjustments.count }
    end

    it "does not connect the promotion to the order" do
      expect { subject }.not_to change { order.friendly_order_promotions.count }
    end
  end
end
