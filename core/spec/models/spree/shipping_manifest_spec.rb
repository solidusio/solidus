require 'spec_helper'

module Spree
  describe ShippingManifest, type: :model do
    let!(:store) { create :store }
    let(:order) { Order.create! }
    let(:variant) { create :variant }
    let!(:shipment) { create(:shipment, state: 'pending', order: order) }
    let(:manifest) { described_class.new(inventory_units: inventory_units) }

    def build_unit(variant, attrs = {})
      attrs = { order: order, variant: variant, shipment: shipment }.merge(attrs)
      attrs[:line_item] = attrs[:order].contents.add(attrs[:variant])
      InventoryUnit.new(attrs)
    end

    subject{ manifest }

    describe "#items" do
      context 'empty' do
        let(:inventory_units) { [] }
        it "has correct item" do
          expect(manifest.items.count).to eq 0
        end
      end

      context 'single unit' do
        let(:inventory_units) { [build_unit(variant)] }
        it "has correct item" do
          expect(manifest.items.count).to eq 1
          expect(manifest.items[0]).to have_attributes(
            variant: variant,
            quantity: 1,
            states: { "on_hand" => 1 }
          )
        end
      end

      context 'two units of same variant' do
        let(:inventory_units) { [build_unit(variant), build_unit(variant)] }
        it "has correct item" do
          expect(manifest.items.count).to eq 1
          expect(manifest.items[0]).to have_attributes(
            variant: variant,
            quantity: 2,
            states: { "on_hand" => 2 }
          )
        end
      end

      context 'two units of different variants' do
        let(:variant2){ create :variant }
        let(:inventory_units) { [build_unit(variant), build_unit(variant2)] }
        it "has correct item" do
          expect(manifest.items.count).to eq 2
          expect(manifest.items[0]).to have_attributes(
            variant: variant,
            quantity: 1,
            states: { "on_hand" => 1 }
          )
          expect(manifest.items[1]).to have_attributes(
            variant: variant2,
            quantity: 1,
            states: { "on_hand" => 1 }
          )
        end
      end
    end

    describe "#for_order" do
      let!(:order2) { Order.create! }
      context 'single unit' do
        let(:inventory_units) { [build_unit(variant)] }
        it "has single ManifestItem in correct order" do
          expect(manifest.for_order(order).items.count).to eq 1
        end

        it "has no ManifestItem in other order" do
          expect(manifest.for_order(order2).items.count).to eq 0
        end
      end

      context 'one units in each order' do
        let(:inventory_units) { [build_unit(variant), build_unit(variant, order: order2)] }
        it "has single ManifestItem in first order" do
          expect(manifest.for_order(order).items.count).to eq 1
        end

        it "has single ManifestItem in second order" do
          expect(manifest.for_order(order2).items.count).to eq 1
        end
      end
    end
  end
end
