# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UnitCancel do
  let(:unit_cancel) { Spree::UnitCancel.create!(inventory_unit: inventory_unit, reason: Spree::UnitCancel::SHORT_SHIP) }
  let(:inventory_unit) { create(:inventory_unit) }

  describe '#adjust!' do
    subject { unit_cancel.adjust! }

    it "creates an adjustment with the correct attributes" do
      expect { subject }.to change{ Spree::Adjustment.count }.by(1)

      adjustment = Spree::Adjustment.last
      expect(adjustment.adjustable).to eq inventory_unit.line_item
      expect(adjustment.amount).to eq(-10.0)
      expect(adjustment.order).to eq inventory_unit.order
      expect(adjustment.label).to eq "Cancellation - Short Ship"
      expect(adjustment).to be_eligible
      expect(adjustment).to be_finalized
    end

    context "when an adjustment has already been created" do
      before { unit_cancel.adjust! }

      it "raises" do
        expect { subject }.to raise_error("Adjustment is already created")
      end
    end
  end

  describe '#compute_amount' do
    subject { unit_cancel.compute_amount(line_item) }

    let(:line_item) { inventory_unit.line_item }
    let!(:inventory_unit2) { create(:inventory_unit, line_item: inventory_unit.line_item) }

    context "all inventory on the line item are not canceled" do
      it "divides the line item total by the inventory units size" do
        expect(subject).to eq(-5.0)
      end
    end

    context "some inventory on the line item is canceled" do
      before { inventory_unit2.cancel! }

      it "divides the line item total by the uncanceled units size" do
        expect(subject).to eq(-10.0)
      end
    end

    context "it is called with a line item that doesnt belong to the inventory unit" do
      let(:line_item) { create(:line_item) }

      it "raises an error" do
        expect { subject }.to raise_error RuntimeError, "Adjustable does not match line item"
      end
    end

    context "multiple inventory units" do
      let(:order) { create(:order_with_line_items) }
      let(:line_item) do
        # Change our quantity to 4
        order.line_items.first.quantity = 4
        # Make sure that there are no inventory_units before
        order.line_items.first.inventory_units.clear
        order.line_items.first
      end

      let(:inventory_units) do
        [
          create(:inventory_unit, line_item: line_item),
          create(:inventory_unit, line_item: line_item),
          create(:inventory_unit, line_item: line_item),
          create(:inventory_unit, line_item: line_item),
        ]
      end

      it "properly creates adjustments for line_item" do
        inventory_units.each do |inventory_unit|
          Spree::UnitCancel.create!(inventory_unit: inventory_unit, reason: Spree::UnitCancel::SHORT_SHIP).adjust!
          inventory_unit.cancel!
        end
        expect(line_item.total.to_d).to eq(0)
      end
    end
  end
end
