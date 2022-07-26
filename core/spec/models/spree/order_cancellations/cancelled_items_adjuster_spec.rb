# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderCancellations::CancelledItemsAdjuster do
  let(:order) { create(:order_ready_to_ship) }
  subject { described_class.new(order).adjust! }

  it "does not change anything on an order without canceled items" do
    expect { subject }.not_to change { order.line_items.sum(&:total_before_tax) }
  end

  context "if there is a canceled item" do
    before do
      Spree::OrderCancellations.new(order).short_ship([order.inventory_units.first])
      # manually update the value of the cancellation adjustment
      order.line_items.first.adjustments.detect(&:cancellation?).update(amount: -2)
    end

    it "changes the line item's total before tax" do
      expect { subject }.to change { order.reload.line_items.sum(&:total_before_tax) }
    end
  end
end
