require 'spec_helper'

module Spree
  module Stock
    describe Coordinator do
      let!(:order) { create(:order_with_line_items, line_items_count: 2) }

      subject { Coordinator.new(order) }

      context "packages" do
        it "builds, prioritizes and estimates" do
          subject.should_receive(:build_location_configured_packages).ordered
          subject.should_receive(:build_packages).ordered
          subject.should_receive(:prioritize_packages).ordered
          subject.should_receive(:estimate_packages).ordered
          subject.packages
        end
      end

      describe "#shipments" do
        let(:packages) { [build(:stock_package_fulfilled), build(:stock_package_fulfilled)] }

        before { subject.stub(:packages).and_return(packages) }

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
        it "builds a package for all active stock locations" do
          subject.packages.count == StockLocation.count
        end

        context "missing stock items in active stock location" do
          let!(:another_location) { create(:stock_location, propagate_all_variants: false) }

          it "builds packages only for valid active stock locations" do
            subject.build_packages.count.should == (StockLocation.count - 1)
          end
        end
      end

      context "build location configured packages" do
        context "there are configured stock locations" do
          let(:stock_location) { order.variants.first.stock_locations.first }
          let!(:stock_location_2) { create(:stock_location) }

          before do
            line_item_1 = order.line_items.first
            line_item_2 = order.line_items.last
            order.order_stock_locations.create(stock_location_id: stock_location.id, quantity: line_item_1.quantity, variant_id: line_item_1.variant_id)
            order.order_stock_locations.create(stock_location_id: stock_location_2.id, quantity: line_item_2.quantity, variant_id: line_item_2.variant_id)
          end

          it "builds a package for each associated stock location" do
            packages = subject.build_location_configured_packages
            expect(packages.count).to eq(2)
            expect(packages.map(&:stock_location)).to eq([stock_location, stock_location_2])
          end
        end
        context "there are no configured stock locations" do
          it "doesn't build any packages" do
            packages = subject.build_location_configured_packages
            expect(packages.count).to eq(0)
          end
        end
      end
    end
  end
end
