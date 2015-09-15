require 'spec_helper'

describe Spree::UnreturnedItemCharger do
  let(:shipped_order) { create(:shipped_order, line_items_count: 1, with_cartons: false) }
  let(:original_shipment) { shipped_order.shipments.first }
  let(:original_stock_location) { original_shipment.stock_location }
  let(:original_inventory_unit) { shipped_order.inventory_units.first }
  let(:original_variant) { original_inventory_unit.variant }
  let(:exchange_shipment) do
    create(:shipment,
           order: shipped_order,
           state: 'shipped',
           stock_location: original_stock_location,
           created_at: 5.days.ago)
  end
  let(:exchange_inventory_unit) { exchange_shipment.inventory_units.first }
  let(:return_item) do
    create(:exchange_return_item,
           inventory_unit: original_inventory_unit,
           exchange_inventory_unit: exchange_inventory_unit)
  end

  let!(:unreturned_item_charger) { Spree::UnreturnedItemCharger.new(exchange_shipment, [return_item]) }

  before do
    exchange_inventory_unit.ship!
  end

  describe "#charge_for_items" do
    before do
      original_variant.update_attributes!(track_inventory: true)
      original_variant.stock_items.update_all(backorderable: false)
    end

    subject { unreturned_item_charger.charge_for_items }

    context "new order is not an unreturned exchange" do
      before do
        allow_any_instance_of(Spree::Shipment).to receive(:update_attributes!)
      end

      it "raises an error" do
        expect { subject }.to raise_error(Spree::UnreturnedItemCharger::ChargeFailure, 'order is not an unreturned exchange')
      end
    end

    context "there's an error transitioning the new order's state" do
      before do
        allow_any_instance_of(Spree::Order).to receive(:next).and_return(false)
      end

      it "raises an error" do
        expect { subject }.to raise_error(Spree::UnreturnedItemCharger::ChargeFailure, 'order did not reach the confirm state')
      end
    end

    context "item is now out of stock" do
      before do
        original_variant.stock_items.map { |si| si.set_count_on_hand(0) }
      end

      it "creates a new completed order" do
        expect { subject }.to change { Spree::Order.count }.by(1)
        new_order = exchange_inventory_unit.shipment.order.reload
        expect(new_order).to_not eq(shipped_order)
        expect(new_order.completed?).to eq true
      end
    end
  end
end
