require 'spec_helper'

module Spree
  module Stock
    describe Coordinator, type: :model do
      let(:order) { create(:order_with_line_items, line_items_count: 2) }

      subject { Coordinator.new(order) }

      describe "#shipments" do
        it "builds, prioritizes and estimates" do
          expect(subject).to receive(:build_location_configured_packages).ordered.and_call_original
          expect(subject).to receive(:build_packages).ordered.and_call_original
          expect(subject).to receive(:prioritize_packages).ordered.and_call_original
          expect(subject).to receive(:estimate_packages).ordered.and_call_original
          expect(subject).to receive(:validate_packages).ordered.and_call_original
          subject.shipments
        end

        it 'uses the pluggable estimator class' do
          expect(Spree::Config.stock).to receive(:estimator_class).and_call_original
          subject.shipments
        end

        it 'builds shipments' do
          expect(subject.shipments.size).to eq(1)
        end

        it "builds a shipment for all active stock locations" do
          subject.shipments.count == StockLocation.count
        end

        context "missing stock items in active stock location" do
          let!(:another_location) { create(:stock_location, propagate_all_variants: false) }

          it "builds shipments only for valid active stock locations" do
            expect(subject.shipments.count).to eq(StockLocation.count - 1)
          end
        end

        it "does not unintentionally add shipments to the order" do
          subject.shipments
          expect {
            order.update!
          }.not_to change {
            order.shipments.count
          }
        end
      end

      # regression spec
      context "when there is one unit that has stock in a stock location that a non-tracked unit has no stock item in" do
        let!(:stock_location_1) { create(:stock_location, propagate_all_variants: false, active: true) }
        let!(:stock_location_2) { create(:stock_location, propagate_all_variants: false, active: true) }

        let!(:variant_1) do
          create(:variant, track_inventory: true).tap do |variant|
            variant.stock_items.destroy_all
            stock_item = variant.stock_items.create!(stock_location: stock_location_1)
            stock_item.set_count_on_hand(10)
          end
        end
        let!(:variant_2) do
          create(:variant, track_inventory: false).tap do |variant|
            variant.stock_items.destroy_all
            stock_item = variant.stock_items.create!(stock_location: stock_location_2)
            stock_item.set_count_on_hand(0)
          end
        end

        let!(:order) { create(:order, line_items: [create(:line_item, variant: variant_1), create(:line_item, variant: variant_2)]) }

        it "splits the inventory units to stock locations that they have stock items for" do
          shipments = subject.shipments

          expect(shipments.size).to eq 2

          location_1_shipment = shipments.detect { |p| p.stock_location == stock_location_1 }
          location_2_shipment = shipments.detect { |p| p.stock_location == stock_location_2 }

          expect(location_1_shipment).to be_present
          expect(location_2_shipment).to be_present

          expect(location_1_shipment.inventory_units.map(&:variant)).to eq [variant_1]
          expect(location_2_shipment.inventory_units.map(&:variant)).to eq [variant_2]
        end
      end

      context "with no backordering" do
        let!(:stock_location_1) { create(:stock_location, propagate_all_variants: false, active: true) }

        let!(:variant) { create(:variant, track_inventory: true) }

        before do
          stock_item1 = variant.stock_items.create!(stock_location: stock_location_1, backorderable: false)
          stock_item1.set_count_on_hand(location_1_inventory)
        end

        let!(:order) { create(:order) }
        let!(:line_item) { create(:line_item, order: order, variant: variant, quantity: 5) }
        before { order.reload }
        let(:shipments) { subject.shipments }

        shared_examples "a fulfillable package" do
          it "packages correctly" do
            expect(shipments).not_to be_empty
            inventory_units = shipments.flat_map { |s| s.inventory_units }
            expect(inventory_units.size).to eq(5)
            expect(inventory_units.uniq.size).to eq(5)
          end
        end

        shared_examples "an unfulfillable package" do
          it "raises exception" do
            expect{ shipments }.to raise_error(Spree::Order::InsufficientStock)
          end
        end

        context 'with no stock locations' do
          let(:location_1_inventory) { 0 }
          before { variant.stock_items.destroy_all }
          it_behaves_like "an unfulfillable package"
        end

        context 'with a single stock location' do
          context "with no inventory" do
            let(:location_1_inventory) { 0 }
            it_behaves_like "an unfulfillable package"
          end

          context "with insufficient inventory" do
            let(:location_1_inventory) { 1 }
            it_behaves_like "an unfulfillable package"
          end

          context "with sufficient inventory" do
            let(:location_1_inventory) { 5 }
            it_behaves_like "a fulfillable package"
          end
        end

        context 'with two stock locations' do
          let!(:stock_location_2) { create(:stock_location, propagate_all_variants: false, active: true) }
          before do
            stock_item2 = variant.stock_items.create!(stock_location: stock_location_2, backorderable: false)
            stock_item2.set_count_on_hand(location_2_inventory)
          end

          context "with no inventory" do
            let(:location_1_inventory) { 0 }
            let(:location_2_inventory) { 0 }
            it_behaves_like "an unfulfillable package"
          end

          context "with some but insufficient inventory in each location" do
            let(:location_1_inventory) { 1 }
            let(:location_2_inventory) { 1 }
            it_behaves_like "an unfulfillable package"
          end

          context "has sufficient inventory in the first location" do
            let(:location_1_inventory) { 5 }
            let(:location_2_inventory) { 0 }
            it_behaves_like "a fulfillable package"
          end

          context "has sufficient inventory in the second location" do
            let(:location_1_inventory) { 0 }
            let(:location_2_inventory) { 5 }
            it_behaves_like "a fulfillable package"
          end

          context "with sufficient inventory only across both locations" do
            let(:location_1_inventory) { 2 }
            let(:location_2_inventory) { 3 }
            before { pending "This is broken. The coordinator packages this incorrectly" }
            it_behaves_like "a fulfillable package"
          end

          context "has sufficient inventory in the second location and some in the first" do
            let(:location_1_inventory) { 2 }
            let(:location_2_inventory) { 5 }
            it_behaves_like "a fulfillable package"
          end

          context "has sufficient inventory in the first location and some in the second" do
            let(:location_1_inventory) { 5 }
            let(:location_2_inventory) { 2 }
            it_behaves_like "a fulfillable package"
          end

          context "with sufficient inventory in both locations" do
            let(:location_1_inventory) { 5 }
            let(:location_2_inventory) { 5 }
            it_behaves_like "a fulfillable package"
          end
        end
      end

      context "build location configured packages" do
        context "there are configured stock locations" do
          let!(:stock_location) { order.variants.first.stock_locations.first }
          let!(:stock_location_2) { create(:stock_location) }

          before do
            line_item_1 = order.line_items.first
            line_item_2 = order.line_items.last
            order.order_stock_locations.create(stock_location_id: stock_location.id, quantity: line_item_1.quantity, variant_id: line_item_1.variant_id)
            order.order_stock_locations.create(stock_location_id: stock_location_2.id, quantity: line_item_2.quantity, variant_id: line_item_2.variant_id)
          end

          it "builds a shipment for each associated stock location" do
            shipments = subject.shipments
            expect(shipments.map(&:stock_location)).to match_array([stock_location, stock_location_2])
          end
        end
      end
    end
  end
end
