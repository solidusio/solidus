# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderInventory, type: :model do
  let(:order) { create :completed_order_with_totals }
  let(:line_item) { order.line_items.first }
  let(:shipment) { order.shipments.first }
  let(:variant) { subject.variant }
  let(:stock_item) { shipment.stock_location.stock_item(variant) }

  subject { described_class.new(order, line_item) }

  context "insufficient inventory units" do
    let(:old_quantity) { 1 }
    let(:new_quantity) { 3 }

    before do
      line_item.update!(quantity: old_quantity)

      line_item.update_column(:quantity, new_quantity)
      subject.line_item.reload
    end

    it 'creates the proper number of inventory units' do
      expect(line_item.inventory_units.count).to eq(old_quantity)
      subject.verify(shipment)
      expect(line_item.inventory_units.count).to eq(new_quantity)
    end

    it "unstocks items" do
      expect {
        subject.verify(shipment)
      }.to change { stock_item.reload.count_on_hand }.by(-2)
    end

    context "order is not completed" do
      let(:inventory_unit_finalizer) { double(:inventory_unit_finalizer, run!: [true]) }

      before do
        allow(Spree::Stock::InventoryUnitsFinalizer)
          .to receive(:new).and_return(inventory_unit_finalizer)

        order.update_columns completed_at: nil
      end

      it "doesn't finalize the items" do
        expect(inventory_unit_finalizer).to_not receive(:run!)

        subject.verify(shipment)
      end
    end

    context "inventory units state" do
      before { shipment.inventory_units.destroy_all }
      let(:new_quantity) { 5 }

      it 'sets inventory_units state as per stock location availability' do
        stock_item.update_columns(
          backorderable: true,
          count_on_hand: 3
        )

        subject.verify

        units = shipment.inventory_units_for(subject.variant).group_by(&:state)
        expect(units['backordered'].size).to eq(2)
        expect(units['on_hand'].size).to eq(3)
      end
    end

    context "store doesnt track inventory" do
      let(:new_quantity) { 1 }

      before { stub_spree_preferences(track_inventory_levels: false) }

      it "creates on hand inventory units" do
        variant.stock_items.each(&:really_destroy!)

        subject.verify(shipment)

        units = shipment.inventory_units_for(variant)
        expect(units.count).to eq 1
        expect(units.first).to be_on_hand
      end
    end

    context "variant doesnt track inventory" do
      before { variant.update!(track_inventory: false) }
      let(:new_quantity) { 1 }

      it "creates on hand inventory units" do
        variant.stock_items.each(&:really_destroy!)

        subject.verify(shipment)

        units = shipment.inventory_units_for(variant)
        expect(units.count).to eq 1
        expect(units.first).to be_on_hand
      end
    end

    it 'should create stock_movement' do
      expect(subject.send(:add_to_shipment, shipment, 5)).to eq(5)

      stock_item = shipment.stock_location.stock_item(subject.variant)
      movement = stock_item.stock_movements.last
      expect(movement.originator).to eq(shipment)
      expect(movement.quantity).to eq(-5)
    end

    context "calling multiple times" do
      it "creates the correct number of inventory units" do
        line_item.update_columns(quantity: 2)
        subject.verify(shipment)
        expect(line_item.inventory_units.count).to eq(2)

        line_item.update_columns(quantity: 3)
        subject.verify(shipment)
        expect(line_item.inventory_units.count).to eq(3)
      end
    end
  end

  context "#determine_target_shipment" do
    let(:stock_location) { create :stock_location }
    let(:variant) { line_item.variant }

    before do
      subject.verify

      order.shipments.create(stock_location_id: stock_location.id, cost: 5)

      shipped = order.shipments.create(stock_location_id: order.shipments.first.stock_location.id, cost: 10)
      shipped.update_column(:state, 'shipped')
    end

    it 'should select first non-shipped shipment that already contains given variant' do
      shipment = subject.send(:determine_target_shipment)
      expect(shipment.shipped?).to be false
      expect(shipment.inventory_units_for(variant)).not_to be_empty

      expect(variant.stock_location_ids.include?(shipment.stock_location_id)).to be true
    end

    context "when no shipments already contain this varint" do
      before do
        subject.line_item.reload
        subject.inventory_units.destroy_all
      end

      it 'selects first non-shipped shipment that leaves from same stock_location' do
        shipment = subject.send(:determine_target_shipment)
        shipment.reload
        expect(shipment.shipped?).to be false
        expect(shipment.inventory_units_for(variant)).to be_empty
        expect(variant.stock_location_ids.include?(shipment.stock_location_id)).to be true
      end
    end
  end

  context 'when order has too many inventory units' do
    let(:old_quantity) { 3 }
    let(:new_quantity) { 2 }

    before do
      line_item.update!(quantity: old_quantity)

      line_item.update_column(:quantity, new_quantity)
      subject.line_item.reload
    end

    it 'should be a messed up order' do
      expect(order.shipments.first.inventory_units_for(line_item.variant).size).to eq(3)
      expect(line_item.quantity).to eq(2)
    end

    it 'should decrease the number of inventory units' do
      subject.verify
      expect(line_item.inventory_units.count).to eq 2
      expect(order.inventory_units.count).to eq 2
    end

    context "order is not completed" do
      before { order.update_columns(completed_at: nil) }

      it "doesn't restock items" do
        expect(shipment.stock_location).not_to receive(:restock)

        expect {
          subject.verify(shipment)
        }.not_to change { stock_item.reload.count_on_hand }

        expect(line_item.inventory_units.count).to eq(new_quantity)
      end
    end

    it 'should change count_on_hand' do
      expect {
        subject.verify(shipment)
      }.to change { stock_item.reload.count_on_hand }.by(1)
    end

    it 'should create stock_movement' do
      stock_item = shipment.stock_location.stock_item(variant)

      expect {
        subject.verify(shipment)
      }.to change { stock_item.stock_movements.count }.by(1)

      movement = stock_item.stock_movements.last
      expect(movement.originator).to eq shipment
      expect(movement.quantity).to eq(1)
    end

    context 'with some backordered' do
      let(:new_quantity) { 1 }

      before do
        line_item.inventory_units[0].update_columns(state: 'backordered')
        line_item.inventory_units[1].update_columns(state: 'on_hand')
        line_item.inventory_units[2].update_columns(state: 'backordered')
      end

      it 'should destroy backordered units first' do
        on_hand_unit = line_item.inventory_units.find_by state: 'on_hand'

        subject.verify(shipment)

        expect(line_item.inventory_units.reload).to eq([on_hand_unit])
      end
    end

    context 'with some shipped items' do
      let(:old_quantity) { 2 }
      let(:new_quantity) { 1 }

      let(:shipped_unit) { line_item.inventory_units[0] }
      before do
        shipped_unit.update_columns(state: 'shipped')
      end

      it 'should destroy unshipped units first' do
        subject.verify(shipment)

        expect(line_item.inventory_units.reload).to eq([shipped_unit])
      end

      context 'trying to remove shipped units' do
        let(:new_quantity) { 0 }

        it 'only attempts to destroy as many units as are eligible, and return amount destroyed' do
          subject.verify(shipment)

          expect(line_item.inventory_units.reload).to eq([shipped_unit])
        end
      end
    end

    context 'destroying all units' do
      let(:new_quantity) { 0 }

      it 'should destroy shipment' do
        expect {
          subject.verify(shipment)
        }.to change{ order.shipments.count }.from(1).to(0)
      end
    end

    context "inventory unit line item and variant points to different products" do
      let(:new_quantity) { 0 }
      let(:different_line_item) { create(:line_item, order: order) }

      let!(:different_inventory) do
        shipment.set_up_inventory("on_hand", variant, order, different_line_item)
      end

      it "removes only units that match both line item and variant" do
        subject.verify(shipment)

        expect(different_inventory.reload).to be_persisted
      end
    end
  end
end
