# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::InventoryUnit, type: :model do
  let(:stock_location) { create(:stock_location_with_items) }
  let(:stock_item) { stock_location.stock_items.order(:id).first }
  let(:line_item) { create(:line_item, variant: stock_item.variant) }

  describe ".cancelable" do
    let!(:pending_unit) { create(:inventory_unit, pending: true) }
    let!(:non_pending_unit) { create(:inventory_unit, pending: false) }

    subject { described_class.cancelable }

    it { is_expected.to contain_exactly(non_pending_unit) }
  end

  context "#backordered_for_stock_item" do
    let(:order) do
      order = create(:order, state: 'complete', ship_address: create(:ship_address))
      order.completed_at = Time.current
      create(:shipment, order: order, stock_location: stock_location)
      order.shipments.reload
      create(:line_item, order: order, variant: stock_item.variant)
      order.line_items.reload
      order.tap(&:save!)
    end

    let(:shipment) do
      order.shipments.first
    end

    let(:shipping_method) do
      shipment.shipping_methods.first
    end

    let!(:unit) do
      unit = shipment.inventory_units.first
      unit.state = 'backordered'
      unit.variant_id = stock_item.variant.id
      unit.line_item = line_item
      unit.tap(&:save!)
    end

    before do
      stock_item.set_count_on_hand(-2)
    end

    # Regression for https://github.com/spree/spree/issues/3066
    it "returns modifiable objects" do
      units = Spree::InventoryUnit.backordered_for_stock_item(stock_item)
      units.first.save!
    end

    it "finds inventory units from its stock location when the unit's variant matches the stock item's variant" do
      expect(Spree::InventoryUnit.backordered_for_stock_item(stock_item)).to match_array([unit])
    end

    it "does not find inventory units that aren't backordered" do
      on_hand_unit = shipment.inventory_units.build
      on_hand_unit.state = 'on_hand'
      on_hand_unit.line_item = line_item
      on_hand_unit.variant = stock_item.variant
      on_hand_unit.save!

      expect(Spree::InventoryUnit.backordered_for_stock_item(stock_item)).not_to include(on_hand_unit)
    end

    it "does not find inventory units that don't match the stock item's variant" do
      other_variant_unit = shipment.inventory_units.build
      other_variant_unit.state = 'backordered'
      other_variant_unit.line_item = line_item
      other_variant_unit.variant = create(:variant)
      other_variant_unit.save!

      expect(Spree::InventoryUnit.backordered_for_stock_item(stock_item)).not_to include(other_variant_unit)
    end

    it "does not change shipping cost when fulfilling the order" do
      current_shipment_cost = shipment.cost
      shipping_method.calculator.set_preference(:amount, current_shipment_cost + 5.0)
      stock_item.set_count_on_hand(0)
      expect(shipment.reload.cost).to eq(current_shipment_cost)
    end

    context "other shipments" do
      let(:other_order) do
        order = create(:order)
        order.state = 'payment'
        order.completed_at = nil
        order.tap(&:save!)
      end

      let(:other_shipment) do
        shipment = Spree::Shipment.new
        shipment.stock_location = stock_location
        shipment.shipping_methods << create(:shipping_method)
        shipment.order = other_order
        shipment.tap(&:save!)
      end

      let!(:other_unit) do
        unit = other_shipment.inventory_units.build
        unit.state = 'backordered'
        unit.variant_id = stock_item.variant.id
        unit.line_item = line_item
        unit.tap(&:save!)
      end

      it "does not find inventory units belonging to incomplete orders" do
        expect(Spree::InventoryUnit.backordered_for_stock_item(stock_item)).not_to include(other_unit)
      end
    end
  end

  context "variants discarded" do
    let!(:unit) { create(:inventory_unit) }

    it "can still fetch variant" do
      unit.variant.discard
      expect(unit.reload.variant).to be_a Spree::Variant
    end

    it "can still fetch variants by eager loading (remove default_scope)" do
      skip "find a way to remove default scope when eager loading associations"
      unit.variant.discard
      expect(Spree::InventoryUnit.joins(:variant).includes(:variant).first.variant).to be_a Spree::Variant
    end
  end

  context "#finalize_units!" do
    let!(:stock_location) { create(:stock_location) }
    let(:variant) { create(:variant) }
    let(:inventory_units) {
      [
      create(:inventory_unit, variant: variant),
      create(:inventory_unit, variant: variant)
    ]
    }

    it "should create a stock movement" do
      expect(Spree::Deprecation).to receive(:warn)
      Spree::InventoryUnit.finalize_units!(inventory_units)
      expect(inventory_units.any?(&:pending)).to be false
    end
  end

  describe "#current_or_new_return_item" do
    subject { inventory_unit.current_or_new_return_item }

    context "associated with a return item" do
      let(:return_item) { create(:return_item) }
      let(:inventory_unit) { return_item.inventory_unit }

      it "returns a persisted return item" do
        expect(subject).to be_persisted
      end

      it "returns it's associated return_item" do
        expect(subject).to eq return_item
      end
    end

    context "no associated return item" do
      let(:inventory_unit) { create(:inventory_unit) }

      it "returns a new return item" do
        expect(subject).to_not be_persisted
      end

      it "associates itself to the new return_item" do
        expect(subject.inventory_unit).to eq inventory_unit
      end
    end
  end

  describe '#additional_tax_total' do
    let(:quantity) { 2 }
    let(:line_item_additional_tax_total) { 10.00 }
    let(:line_item) do
      build(:line_item, {
        quantity: quantity,
        additional_tax_total: line_item_additional_tax_total
      })
    end

    subject do
      build(:inventory_unit, line_item: line_item)
    end

    it 'is the correct amount' do
      expect(subject.additional_tax_total).to eq line_item_additional_tax_total / quantity
    end
  end

  describe '#included_tax_total' do
    let(:quantity) { 2 }
    let(:line_item_included_tax_total) { 10.00 }
    let(:line_item) do
      build(:line_item, {
        quantity: quantity,
        included_tax_total: line_item_included_tax_total
      })
    end

    subject do
      build(:inventory_unit, line_item: line_item)
    end

    it 'is the correct amount' do
      expect(subject.included_tax_total).to eq line_item_included_tax_total / quantity
    end
  end

  describe '#additional_tax_total' do
    let(:quantity) { 2 }
    let(:line_item_additional_tax_total) { 10.00 }
    let(:line_item) do
      build(:line_item, {
        quantity: quantity,
        additional_tax_total: line_item_additional_tax_total
      })
    end

    subject do
      build(:inventory_unit, line_item: line_item)
    end

    it 'is the correct amount' do
      expect(subject.additional_tax_total).to eq line_item_additional_tax_total / quantity
    end
  end

  describe '#included_tax_total' do
    let(:quantity) { 2 }
    let(:line_item_included_tax_total) { 10.00 }
    let(:line_item) do
      build(:line_item, {
        quantity: quantity,
        included_tax_total: line_item_included_tax_total
      })
    end

    subject do
      build(:inventory_unit, line_item: line_item)
    end

    it 'is the correct amount' do
      expect(subject.included_tax_total).to eq line_item_included_tax_total / quantity
    end
  end

  describe "#exchange_requested?" do
    subject { inventory_unit.exchange_requested? }

    context "return item contains inventory unit and was for an exchange" do
      let(:exchange_return_item) { create(:exchange_return_item) }
      let(:inventory_unit) { exchange_return_item.inventory_unit }
      it { is_expected.to eq true }
    end

    context "return item does not contain inventory unit" do
      let(:inventory_unit) { create(:inventory_unit) }
      it { is_expected.to eq false }
    end
  end

  context "destroy prevention" do
    it "can be destroyed when on hand" do
      inventory_unit = create(:inventory_unit, state: "on_hand")
      expect(inventory_unit.destroy).to be_truthy
      expect { inventory_unit.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "can be destroyed when backordered" do
      inventory_unit = create(:inventory_unit, state: "backordered")
      expect(inventory_unit.destroy).to be_truthy
      expect { inventory_unit.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cannot be destroyed when shipped" do
      inventory_unit = create(:inventory_unit, state: "shipped")
      expect(inventory_unit.destroy).to eq false
      expect(inventory_unit.errors.full_messages.join).to match /Cannot destroy/
      expect { inventory_unit.reload }.not_to raise_error
    end

    it "cannot be destroyed when returned" do
      inventory_unit = create(:inventory_unit, state: "returned")
      expect(inventory_unit.destroy).to eq false
      expect(inventory_unit.errors.full_messages.join).to match /Cannot destroy/
      expect { inventory_unit.reload }.not_to raise_error
    end

    it "can be destroyed if its shipment is ready" do
      inventory_unit = create(:order_ready_to_ship).inventory_units.first
      expect(inventory_unit.destroy).to be_truthy
      expect { inventory_unit.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cannot be destroyed if its shipment is shipped" do
      inventory_unit = create(:shipped_order).inventory_units.first
      expect(inventory_unit.destroy).to eq false
      expect(inventory_unit.errors.full_messages.join).to match /Cannot destroy/
      expect { inventory_unit.reload }.not_to raise_error
    end
  end
end
