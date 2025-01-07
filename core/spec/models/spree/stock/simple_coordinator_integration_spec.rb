require "rails_helper"

RSpec.describe "Integrating with the simple coordinator" do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }

  subject { Spree::Stock::SimpleCoordinator.new(order) }

  it 'builds shipments' do
    expect(subject.shipments.size).to eq(1)
  end

  it "builds a shipment for all active stock locations" do
    expect(subject.shipments.count).to eq Spree::StockLocation.count
  end

  context "missing stock items in active stock location" do
    let!(:another_location) { create(:stock_location, propagate_all_variants: false) }

    it "builds shipments only for valid active stock locations" do
      expect(subject.shipments.count).to eq(Spree::StockLocation.count - 1)
    end
  end

  it "does not unintentionally add shipments to the order" do
    subject.shipments
    expect {
      order.recalculate
    }.not_to change {
      order.shipments.count
    }
  end

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

      location_1_shipment = shipments.detect { |shipment| shipment.stock_location == stock_location_1 }
      location_2_shipment = shipments.detect { |shipment| shipment.stock_location == stock_location_2 }

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
      stock_item_one = variant.stock_items.create!(stock_location: stock_location_1, backorderable: false)
      stock_item_one.set_count_on_hand(location_1_inventory)
    end

    let!(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order:, variant:, quantity: 5) }
    before { order.reload }
    let(:shipments) { subject.shipments }

    shared_examples "a fulfillable package" do
      it "packages correctly" do
        expect(shipments).not_to be_empty
        inventory_units = shipments.flat_map(&:inventory_units)
        expect(inventory_units.size).to eq(5)
        expect(inventory_units.uniq.size).to eq(5)
      end
    end

    shared_examples "an unfulfillable package" do
      it "raises exception" do
        expect{ shipments }.to raise_error(Spree::Order::InsufficientStock)
      end

      it 'raises exception and includes unfulfillable items' do
        begin
          expect(shipments).not_to be_empty
        rescue Spree::Order::InsufficientStock => e
          expect(e.items.keys.map(&:id)).to contain_exactly(variant.id)
        end
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
        stock_item_two = variant.stock_items.create!(stock_location: stock_location_2, backorderable: false)
        stock_item_two.set_count_on_hand(location_2_inventory)
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

    context 'with three stock locations' do
      let!(:stock_location_2) { create(:stock_location, propagate_all_variants: false, active: true) }
      let!(:stock_location_3) { create(:stock_location, propagate_all_variants: false, active: true) }
      before do
        stock_item_two = variant.stock_items.create!(stock_location: stock_location_2, backorderable: false)
        stock_item_two.set_count_on_hand(location_2_inventory)

        stock_item_three = variant.stock_items.create!(stock_location: stock_location_3, backorderable: false)
        stock_item_three.set_count_on_hand(location_3_inventory)
      end

      # Regression test for https://github.com/solidusio/solidus/issues/2122
      context "with sufficient inventory in first two locations" do
        let(:location_1_inventory) { 3 }
        let(:location_2_inventory) { 3 }
        let(:location_3_inventory) { 3 }

        it_behaves_like "a fulfillable package"

        it "creates only two packages" do
          expect(shipments.count).to eq(2)
        end
      end

      context "with sufficient inventory only across all three locations" do
        let(:location_1_inventory) { 2 }
        let(:location_2_inventory) { 2 }
        let(:location_3_inventory) { 2 }

        it_behaves_like "a fulfillable package"

        it "creates three packages" do
          expect(shipments.count).to eq(3)
        end
      end

      context "with sufficient inventory only across all three locations" do
        let(:location_1_inventory) { 2 }
        let(:location_2_inventory) { 2 }
        let(:location_3_inventory) { 2 }

        it_behaves_like "a fulfillable package"

        it "creates three packages" do
          expect(shipments.count).to eq(3)
        end
      end
    end
  end

  context "when custom coordinator options are passed" do
    let!(:order) {
      create :order_with_line_items, line_items_attributes: [{variant: create(:product_in_stock).master }]
    }

    subject {
      Spree::Stock::SimpleCoordinator.new(order, coordinator_options:)
    }

    describe "to customize the estimator's behavior" do
      let(:coordinator_options) { {arbitrary_shipping_rates: [my_shipping_rate]} }
      let(:my_shipping_rate) { create(:shipping_method).shipping_rates.new }

      around do |example|
        MyEstimator = Class.new(Spree::Stock::Estimator) do
          def shipping_rates(package, _frontend_only = true)
            raise ShipmentRequired if package.shipment.nil?
            raise OrderRequired if package.shipment.order.nil?

            first_shipping_rate = coordinator_options[:arbitrary_shipping_rates]&.first

            if first_shipping_rate
              first_shipping_rate.selected = true
              return [first_shipping_rate]
            else
              raise StandardError, "no shipping rate!"
            end
          end
        end

        original_estimator_class = Spree::Config.stock.estimator_class.to_s
        Spree::Config.stock.estimator_class = MyEstimator.to_s
        example.run
        Spree::Config.stock.estimator_class = original_estimator_class
      end

      it "uses the options" do
        expect(subject.shipments.first.selected_shipping_rate)
          .to eq my_shipping_rate
      end
    end

    describe "to customize the inventory unit builder's behavior" do
      let(:coordinator_options) { {multiplier: 4} }

      around do |example|
        MyInventoryUnitBuilder = Class.new(Spree::Stock::InventoryUnitBuilder) do
          def units
            units = []
            coordinator_options[:multiplier].times do
              units = units.concat(super)
            end
            units
          end
        end

        original_inventory_unit_builder_class =
          Spree::Config.stock.inventory_unit_builder_class
        Spree::Config.stock.inventory_unit_builder_class =
          MyInventoryUnitBuilder.to_s
        example.run
        Spree::Config.stock.inventory_unit_builder_class =
          original_inventory_unit_builder_class.to_s
      end

      it "" do
        expect(subject.shipments.first.inventory_units.size).to eq(4)
      end
    end

    describe "to customize the allocator's behavior" do
      let(:coordinator_options) { {force_backordered: true} }

      around do |example|
        MyAllocator = Class.new(Spree::Stock::Allocator::OnHandFirst) do
          def allocate_inventory(desired)
            if coordinator_options[:force_backordered]
              backordered = allocate(availability.backorderable_by_stock_location_id, desired)
              desired -= backordered.values.reduce(&:+) if backordered.present?
              [{}, backordered, desired]
            else
              super
            end
          end
        end

        original_allocator_class = Spree::Config.stock.allocator_class
        Spree::Config.stock.allocator_class = MyAllocator.to_s
        example.run
        Spree::Config.stock.allocator_class =
          original_allocator_class.to_s
      end

      it "uses the options to force backordered allocation" do
        expect(subject.shipments.flat_map(&:inventory_units).all?(&:backordered?)).to be true
      end
    end

    describe "to customize the stock locator filter behavior" do
      let(:coordinator_options) { {force_specific_stock_location: specific_stock_location} }
      let(:specific_stock_location) { create(:stock_location) }

      around do |example|
        MyLocatorFilter = Class.new(Spree::Stock::LocationFilter::Active) do
          def filter
            coordinator_options[:force_specific_stock_location] ?
              [coordinator_options[:force_specific_stock_location]]
              : super
          end
        end

        original_locator_filter_class = Spree::Config.stock.location_filter_class
        Spree::Config.stock.location_filter_class = MyLocatorFilter.to_s
        example.run
        Spree::Config.stock.location_filter_class =
          original_locator_filter_class.to_s
      end

      it "uses the options to force a specific stock location" do
        expect(subject.shipments.map(&:stock_location)).to eq [specific_stock_location]
      end
    end

    describe "to customize the stock location sorters behavior" do
      let(:coordinator_options) { {force_stock_location_order: [stock_location_2, stock_location_1]} }
      let!(:stock_location_1) { create(:stock_location, active: true, propagate_all_variants: true) }
      let!(:stock_location_2) { create(:stock_location, active: true, propagate_all_variants: true) }

      before do
        Spree::StockItem.update_all(count_on_hand: 999)
      end

      around do |example|
        MyLocationSorter = Class.new(Spree::Stock::LocationSorter::DefaultFirst) do
          def sort
            coordinator_options[:force_stock_location_order] || super
          end
        end

        original_location_sorter_class = Spree::Config.stock.location_sorter_class
        Spree::Config.stock.location_sorter_class = MyLocationSorter.to_s
        example.run
        Spree::Config.stock.location_sorter_class =
          original_location_sorter_class.to_s
      end

      it "uses the options to force a specific stock location order" do
        expect(subject.shipments.map(&:stock_location)).to all(eq(stock_location_2))
      end
    end
  end
end
