# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe InventoryUnitsFinalizer, type: :model do
      let(:order)          { build(:order_with_line_items) }
      let(:inventory_unit) { build(:inventory_unit, order: order, variant: order.line_items.first.variant, shipment: order.shipments.first) }
      let(:stock_item) { inventory_unit.variant.stock_items.first }

      before do
        stock_item.set_count_on_hand(10)
        stock_item.update_attributes!(backorderable: false)
        inventory_unit.update_attributes!(pending: true)
      end

      subject { described_class.new([inventory_unit]).run! }

      it "updates the associated inventory units" do
        inventory_unit.update_columns(updated_at: 1.hour.ago)
        expect { subject }.to change { inventory_unit.reload.updated_at }
      end

      it "updates the inventory units to not be pending" do
        expect { subject }.to change { inventory_unit.reload.pending }.to(false)
      end

      it "unstocks the variant" do
        expect { subject }.to change { stock_item.reload.count_on_hand }.from(10).to(9)
      end
    end
  end
end
