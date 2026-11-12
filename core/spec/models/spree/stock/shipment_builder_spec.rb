# frozen_string_literal: true

require "rails_helper"

module Spree
  module Stock
    RSpec.describe ShipmentBuilder, type: :model do
      subject(:shipments) { described_class.new(packages:).call }

      let!(:stock_location) { create(:stock_location) }
      let!(:other_stock_location) { create(:stock_location) }

      let(:order) { create(:order_with_line_items, line_items_count: 1) }
      let(:line_item) { order.line_items.first }
      let(:variant) { line_item.variant }

      # Packages reach the builder holding unsaved inventory units, the way
      # Spree::Stock::PackageBuilder hands them over. The package reads its
      # order back off the units' line item.
      def build_package(location, quantity: 1)
        Spree::Stock::Package.new(location).tap do |package|
          package.add_multiple(
            Array.new(quantity) do
              Spree::InventoryUnit.new(pending: true, variant:, line_item:)
            end,
            :on_hand
          )
        end
      end

      let(:packages) { [build_package(stock_location)] }

      describe "#call" do
        it "builds a shipment per package" do
          expect(shipments.size).to eq 1
          expect(shipments.first).to be_a Spree::Shipment
        end

        it "builds the shipment for the package's stock location" do
          expect(shipments.first.stock_location).to eq stock_location
        end

        it "assigns the shipment back to the package" do
          shipment = shipments.first

          expect(packages.first.shipment).to eq shipment
        end

        it "assigns shipping rates to the shipment" do
          expect(shipments.first.shipping_rates).not_to be_empty
        end

        it "uses the configured estimator class" do
          expect(Spree::Config.stock).to receive(:estimator_class).and_call_original

          shipments
        end

        context "with several packages" do
          let(:packages) do
            [build_package(stock_location), build_package(other_stock_location)]
          end

          it "builds a shipment for each one" do
            expect(shipments.map(&:stock_location))
              .to eq [stock_location, other_stock_location]
          end

          it "assigns each shipment back to its own package" do
            built = shipments

            expect(packages.map(&:shipment)).to eq built
          end
        end

        context "with no packages" do
          let(:packages) { [] }

          it { is_expected.to eq [] }
        end

        context "when an estimator class is given" do
          subject(:shipments) do
            described_class.new(packages:, estimator_class:).call
          end

          let(:shipping_rate) { Spree::ShippingRate.new(cost: 12.34) }
          let(:estimator) { instance_double(Spree::Stock::Estimator) }
          let(:estimator_class) { class_double(Spree::Stock::Estimator, new: estimator) }

          before do
            allow(estimator).to receive(:shipping_rates).and_return([shipping_rate])
          end

          it "takes the shipping rates from that estimator" do
            expect(shipments.first.shipping_rates).to eq [shipping_rate]
          end

          it "asks the estimator for rates for each package" do
            expect(estimator).to receive(:shipping_rates).with(packages.first)

            shipments
          end
        end
      end
    end
  end
end
