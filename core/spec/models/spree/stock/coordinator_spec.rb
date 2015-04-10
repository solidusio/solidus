require 'spec_helper'

module Spree
  module Stock
    describe Coordinator, :type => :model do
      let!(:order) { create(:order_with_line_items) }

      subject { Coordinator.new(order) }

      context "packages" do
        it "builds, prioritizes and estimates" do
          expect(subject).to receive(:build_packages).ordered
          expect(subject).to receive(:prioritize_packages).ordered
          expect(subject).to receive(:estimate_packages).ordered
          subject.packages
        end
      end

      describe "#shipments" do
        let(:packages) { [build(:stock_package_fulfilled), build(:stock_package_fulfilled)] }

        before { allow(subject).to receive(:packages).and_return(packages) }

        it "turns packages into shipments" do
          shipments = subject.shipments
          expect(shipments.count).to eq packages.count
          shipments.each { |shipment| expect(shipment).to be_a Shipment }
        end

        it "puts the order's ship address on the shipments" do
          shipments = subject.shipments
          shipments.each { |shipment| expect(shipment.address).to eq order.ship_address }
        end
      end

      context "build packages" do
        it "builds a package for every stock location" do
          subject.packages.count == StockLocation.count
        end

        context "missing stock items in stock location" do
          let!(:another_location) { create(:stock_location, propagate_all_variants: false) }

          it "builds packages only for valid stock locations" do
            expect(subject.build_packages.count).to eq(StockLocation.count - 1)
          end
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
          packages = subject.packages

          expect(subject.packages.size).to eq 2

          location_1_package = packages.detect { |p| p.stock_location == stock_location_1 }
          location_2_package = packages.detect { |p| p.stock_location == stock_location_2 }

          expect(location_1_package).to be_present
          expect(location_2_package).to be_present

          expect(location_1_package.contents.map(&:inventory_unit).map(&:variant)).to eq [variant_1]
          expect(location_2_package.contents.map(&:inventory_unit).map(&:variant)).to eq [variant_2]
        end
      end
    end
  end
end
