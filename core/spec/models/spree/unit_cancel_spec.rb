# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UnitCancel do
  let(:unit_cancel) { described_class.create!(inventory_unit: inventory_unit, reason: described_class::SHORT_SHIP) }
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

      it "raises an error if dividing by 0" do
        inventory_unit.cancel!
        expect { subject }.to raise_error ZeroDivisionError, "Line Item does not have any inventory units available to cancel"
      end
    end

    context "it is called with a line item that doesnt belong to the inventory unit" do
      let(:line_item) { create(:line_item) }

      it "raises an error" do
        expect { subject }.to raise_error RuntimeError, "Adjustable does not match line item"
      end
    end

    context "multiple inventory units" do
      let(:quantity) { 4 }
      let(:order) { create(:order_with_line_items, line_items_attributes: [{ quantity: quantity }]) }
      let(:line_item) { order.line_items.first }
      let(:inventory_units) { line_item.inventory_units }

      it "has the right amount of inventory units" do
        expect(inventory_units.size).to eq quantity
      end

      it "properly creates adjustments for line_item" do
        inventory_units.each do |inventory_unit|
          described_class.create!(inventory_unit: inventory_unit, reason: described_class::SHORT_SHIP).adjust!
          inventory_unit.cancel!
        end
        expect(line_item.reload.total.to_d).to eq(0)
      end
    end

    context 'when line item has additional taxes' do
      let(:world_zone) { create(:zone, :with_country) }
      let(:tax_category) { create :tax_category }
      let(:product) { create :product, tax_category: tax_category }
      let!(:additional_tax_rate) do
        create(
          :tax_rate,
          name: 'Additional tax',
          tax_categories: [tax_category],
          zone: world_zone,
          included_in_price: false,
          amount: 0.15
        )
      end
      let(:shipping_category) { create :shipping_category }
      let(:shipping_method) do
        create :shipping_method,
               cost: 8.00,
               shipping_categories: [shipping_category],
               tax_category: tax_category,
               zones: [world_zone]
      end
      let(:shipping_address) { create :address, country_iso_code: world_zone.countries.first.iso }
      let(:order) do
        create(
          :order_with_line_items,
          ship_address: shipping_address,
          line_items_attributes: [{ product: product }]
        )
      end
      let(:line_item) { order.line_items.first }
      let(:inventory_unit) { line_item.inventory_units.first }

      before { order.recalculate }

      it 'does not include line item additional taxes' do
        expect(line_item.additional_tax_total).not_to eq 0
        expect(subject).to eq(-5.0)
      end
    end
  end
end
