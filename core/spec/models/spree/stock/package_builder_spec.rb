# frozen_string_literal: true

require "rails_helper"

module Spree
  module Stock
    RSpec.describe PackageBuilder, type: :model do
      subject(:packages) { described_class.new(inventory_units:, stock_locations:).call }

      let!(:stock_location) { create(:stock_location, propagate_all_variants: false) }
      let!(:other_stock_location) { create(:stock_location, propagate_all_variants: false) }

      let(:variant) { create(:variant) }

      let(:stock_locations) { [stock_location, other_stock_location] }

      # Inventory units reach the builder unsaved, the way
      # Spree::Stock::InventoryUnitBuilder hands them over.
      let(:inventory_units) do
        Array.new(desired_quantity) { Spree::InventoryUnit.new(pending: true, variant:) }
      end
      let(:desired_quantity) { 1 }

      let(:count_on_hand) { 0 }
      let(:other_count_on_hand) { 0 }
      let(:backorderable) { false }

      before do
        variant.stock_items.create!(stock_location:, backorderable:)
          .set_count_on_hand(count_on_hand)

        variant.stock_items.create!(stock_location: other_stock_location, backorderable: false)
          .set_count_on_hand(other_count_on_hand)
      end

      describe "#call" do
        context "when a single stock location can fulfill the inventory units" do
          let(:count_on_hand) { 1 }

          it "builds one package for that stock location" do
            expect(packages.map(&:stock_location)).to eq [stock_location]
          end

          it "puts the inventory units in the package as on hand" do
            expect(packages.first.on_hand.map(&:inventory_unit)).to eq inventory_units
            expect(packages.first.backordered).to be_empty
          end

          it "uses the configured allocator class" do
            expect(Spree::Config.stock).to receive(:allocator_class).and_call_original

            packages
          end
        end

        context "when the inventory units are spread across stock locations" do
          let(:desired_quantity) { 2 }
          let(:count_on_hand) { 1 }
          let(:other_count_on_hand) { 1 }

          it "builds a package per stock location" do
            expect(packages.map(&:stock_location)).to eq [stock_location, other_stock_location]
          end

          it "assigns each inventory unit to exactly one package" do
            packaged_units = packages.flat_map(&:contents).map(&:inventory_unit)

            expect(packaged_units).to match_array inventory_units
          end
        end

        context "when the stock locations are given in a particular order" do
          let(:count_on_hand) { 1 }
          let(:other_count_on_hand) { 1 }
          let(:stock_locations) { [other_stock_location, stock_location] }

          it "allocates from the first stock location it is given" do
            expect(packages.map(&:stock_location)).to eq [other_stock_location]
          end

          context "when more than one stock location is needed" do
            let(:desired_quantity) { 2 }

            it "builds the packages in the order the stock locations were given" do
              expect(packages.map(&:stock_location)).to eq [other_stock_location, stock_location]
            end
          end
        end

        context "when a stock location has no inventory to contribute" do
          let(:other_count_on_hand) { 1 }

          it "skips that stock location" do
            expect(packages.map(&:stock_location)).to eq [other_stock_location]
          end
        end

        context "when a stock location can only partly fulfill the inventory units" do
          let(:desired_quantity) { 2 }
          let(:count_on_hand) { 1 }
          let(:backorderable) { true }

          it "combines the on hand and backordered units into a single package" do
            expect(packages.map(&:stock_location)).to eq [stock_location]
            expect(packages.first.on_hand.count).to eq 1
            expect(packages.first.backordered.count).to eq 1
          end
        end

        context "when the inventory units cannot be fulfilled" do
          it "raises an insufficient stock error listing the leftover items" do
            expect { packages }.to raise_error(Spree::Order::InsufficientStock) { |error|
              expect(error.items).to eq(variant => 1)
            }
          end
        end

        context "when a stock location with inventory is not given" do
          let(:stock_locations) { [stock_location] }
          let(:other_count_on_hand) { 1 }

          it "does not allocate inventory from it" do
            expect { packages }.to raise_error(Spree::Order::InsufficientStock)
          end
        end

        context "when an allocator class is given" do
          subject(:packages) do
            described_class.new(inventory_units:, stock_locations:, allocator_class:).call
          end

          let(:allocator) { instance_double(Spree::Stock::Allocator::OnHandFirst) }
          let(:allocator_class) { class_double(Spree::Stock::Allocator::OnHandFirst, new: allocator) }

          before do
            allow(allocator).to receive(:allocate_inventory).and_return(
              [
                {other_stock_location.id => Spree::StockQuantities.new(variant => 1)},
                {},
                Spree::StockQuantities.new
              ]
            )
          end

          it "builds packages from that allocator's allocation" do
            expect(packages.map(&:stock_location)).to eq [other_stock_location]
            expect(packages.first.on_hand.map(&:inventory_unit)).to eq inventory_units
          end
        end
      end
    end
  end
end
