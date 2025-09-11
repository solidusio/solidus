# frozen_string_literal: true

require "rails_helper"
require "benchmark"

RSpec.describe Spree::Shipment, type: :model do
  let(:order) { create(:order_ready_to_ship, line_items_count: 1) }
  let(:shipping_method) { create(:shipping_method, name: "UPS") }
  let(:stock_location) { create(:stock_location) }
  let(:shipment) do
    order.shipments.create!(
      state: "pending",
      cost: 1,
      inventory_units: order.inventory_units,
      shipping_rates: [shipping_rate],
      stock_location:
    )
  end
  let(:shipping_rate) do
    Spree::ShippingRate.create!(
      shipping_method:,
      selected: true
    )
  end

  describe "#total_before_tax" do
    before do
      shipment.update!(cost: 10)
    end
    let!(:admin_adjustment) { create(:adjustment, adjustable: shipment, order: shipment.order, amount: -1, source: nil) }
    let!(:promo_adjustment) { create(:adjustment, adjustable: shipment, order: shipment.order, amount: -2, source: promo_action) }
    let!(:ineligible_promo_adjustment) { create(:adjustment, eligible: false, adjustable: shipment, order: shipment.order, amount: -4, source: promo_action) }
    let(:promo_action) { promo.actions[0] }
    let(:promo) { create(:promotion, :with_line_item_adjustment) }

    it "returns the amount minus any adjustments" do
      expect(shipment.total_before_tax).to eq(10 - 1 - 2)
    end
  end
end
