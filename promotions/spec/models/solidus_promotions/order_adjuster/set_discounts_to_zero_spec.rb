# frozen_string_literal: true

require "rails_helper"
RSpec.describe SolidusPromotions::OrderAdjuster::SetDiscountsToZero do
  subject { described_class.call(order) }
  let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
  let(:benefit) { promotion.benefits.first }
  let(:order) { create(:order_with_line_items) }

  before do
    order.line_items.first.adjustments.create!(source: benefit, order:, amount: -2, label: "Line Item discount")
    order.shipments.first.adjustments.create!(source: benefit, order:, amount: -2, label: "Shipment discount")
    order.shipments.first.shipping_rates.first.discounts.create!(benefit:, amount: -2, label: "Shipping rate discount")
  end

  it "keeps all adjustments and sets their amount to zero" do
    subject
    expect(order.line_items.flat_map(&:adjustments).map(&:amount).all?(&:zero?)).to be true
    expect(order.shipments.flat_map(&:adjustments).map(&:amount).all?(&:zero?)).to be true
    expect(order.shipments.flat_map(&:shipping_rates).flat_map(&:discounts).map(&:amount).all?(&:zero?)).to be true
  end
end
