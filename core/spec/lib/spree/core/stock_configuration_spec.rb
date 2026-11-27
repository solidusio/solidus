# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::StockConfiguration do
  let(:stock_configuration) { described_class.new }

  describe "#coordinator_class" do
    subject { stock_configuration.coordinator_class }

    it "returns Spree::Stock::Coordinator by default" do
      expect(subject).to be ::Spree::Stock::SimpleCoordinator
    end

    it "can be reassigned" do
      MyCoordinator = Class.new
      stock_configuration.coordinator_class = MyCoordinator.to_s

      expect(subject).to be MyCoordinator
    ensure
      Object.send(:remove_const, :MyCoordinator)
    end
  end

  describe "#estimator_class" do
    subject { stock_configuration.estimator_class }

    it "returns Spree::Stock::Estimator" do
      expect(subject).to be ::Spree::Stock::Estimator
    end

    it "can be reassigned" do
      MyEstimator = Class.new
      stock_configuration.estimator_class = MyEstimator.to_s

      expect(subject).to be MyEstimator
    ensure
      Object.send(:remove_const, :MyEstimator)
    end
  end

  describe "#location_filter_class" do
    subject { stock_configuration.location_filter_class }

    it "returns Spree::Stock::LocationFilter::Active by default" do
      expect(subject).to be ::Spree::Stock::LocationFilter::Active
    end

    it "can be reassigned" do
      MyFilter = Class.new
      stock_configuration.location_filter_class = MyFilter.to_s

      expect(subject).to be MyFilter
    ensure
      Object.send(:remove_const, :MyFilter)
    end
  end

  describe "#location_sorter_class" do
    subject { stock_configuration.location_sorter_class }

    it "returns Spree::Stock::LocationSorter::Unsorted by default" do
      expect(subject).to be ::Spree::Stock::LocationSorter::Unsorted
    end

    it "can be reassigned" do
      MySorter = Class.new
      stock_configuration.location_sorter_class = MySorter.to_s

      expect(subject).to be MySorter
    ensure
      Object.send(:remove_const, :MySorter)
    end
  end

  describe "#allocator_class" do
    subject { stock_configuration.allocator_class }

    it "returns Spree::Stock::Allocator::OnHandFirst by default" do
      expect(subject).to be ::Spree::Stock::Allocator::OnHandFirst
    end

    it "can be reassigned" do
      MyAllocator = Class.new
      stock_configuration.allocator_class = MyAllocator.to_s

      expect(subject).to be MyAllocator
    ensure
      Object.send(:remove_const, :MyAllocator)
    end
  end

  describe "#inventory_unit_builder_class" do
    subject { stock_configuration.inventory_unit_builder_class }

    it "returns Spree::Stock::InventoryUnitBuilder by default" do
      expect(subject).to be ::Spree::Stock::InventoryUnitBuilder
    end

    it "can be reassigned" do
      MyInventoryUnitBuilder = Class.new
      stock_configuration.inventory_unit_builder_class = MyInventoryUnitBuilder.to_s

      expect(subject).to be MyInventoryUnitBuilder
    ensure
      Object.send(:remove_const, :MyInventoryUnitBuilder)
    end
  end

  describe "#availability_validator_class" do
    subject { stock_configuration.availability_validator_class }

    let(:stock_configuration) { described_class.new }

    it "returns Spree::Stock::AvailabilityValidator" do
      is_expected.to be ::Spree::Stock::AvailabilityValidator
    end

    it "can be reassigned" do
      MyAvailabilityValidator = Class.new
      stock_configuration.availability_validator_class = MyAvailabilityValidator.to_s

      expect(subject).to be MyAvailabilityValidator
    ensure
      Object.send(:remove_const, :MyAvailabilityValidator)
    end
  end

  describe "#inventory_validator_class" do
    subject { stock_configuration.inventory_validator_class }

    let(:stock_configuration) { described_class.new }

    it "returns Spree::Stock::InventoryValidator" do
      is_expected.to be ::Spree::Stock::InventoryValidator
    end

    it "can be reassigned" do
      MyInventoryValidator = Class.new
      stock_configuration.inventory_validator_class = MyInventoryValidator.to_s

      expect(subject).to be MyInventoryValidator
    ensure
      Object.send(:remove_const, :MyInventoryValidator)
    end
  end

  describe "#build_coordinator" do
    let(:order) { create(:order_with_line_items) }
    let!(:inactive_stock_location) { create(:stock_location, active: false) }

    subject(:coordinator) { stock_configuration.build_coordinator(order) }

    before { allow(Spree.deprecator).to receive(:warn) }

    def build_coordinator_class(&block)
      Class.new do
        attr_reader :order, :kwargs

        class_eval(&block)
      end
    end

    context "with a coordinator that accepts stock_locations" do
      before do
        stock_configuration.coordinator_class = "::Spree::Stock::Coordinator"
      end

      it "passes in the filtered stock locations" do
        expect(coordinator.stock_locations).to match_array(Spree::StockLocation.active)
        expect(coordinator.stock_locations).not_to include(inactive_stock_location)
      end

      it "does not warn about deprecated usage" do
        coordinator
        expect(Spree.deprecator).not_to have_received(:warn)
      end
    end

    context "with the default coordinator" do
      it "passes in the filtered stock locations" do
        expect(coordinator.stock_locations).not_to include(inactive_stock_location)
      end

      it "does not warn about deprecated usage" do
        coordinator
        expect(Spree.deprecator).not_to have_received(:warn)
      end
    end

    context "with a coordinator that accepts any keyword arguments" do
      let(:coordinator_class) do
        build_coordinator_class do
          def initialize(order, **kwargs)
            @order = order
            @kwargs = kwargs
          end
        end
      end

      before do
        allow(stock_configuration).to receive(:coordinator_class).and_return(coordinator_class)
      end

      it "passes in the filtered stock locations" do
        expect(coordinator.kwargs[:stock_locations]).not_to include(inactive_stock_location)
        expect(coordinator.kwargs[:stock_locations]).to be_present
      end

      it "does not warn about deprecated usage" do
        coordinator
        expect(Spree.deprecator).not_to have_received(:warn)
      end
    end

    context "with a coordinator that does not accept stock_locations" do
      let(:coordinator_class) do
        build_coordinator_class do
          def initialize(order, inventory_units: nil)
            @order = order
            @kwargs = {inventory_units:}
          end
        end
      end

      before do
        allow(stock_configuration).to receive(:coordinator_class).and_return(coordinator_class)
      end

      it "builds the coordinator without stock locations" do
        expect(coordinator.order).to eq order
        expect(coordinator.kwargs).not_to have_key(:stock_locations)
      end

      it "warns about deprecated usage" do
        coordinator
        expect(Spree.deprecator).to have_received(:warn).with(/should accept a `stock_locations:` keyword/)
      end
    end

    context "when inventory units are given" do
      let(:inventory_units) { [build(:inventory_unit)] }

      subject(:coordinator) { stock_configuration.build_coordinator(order, inventory_units:) }

      it "passes them to the coordinator" do
        expect(coordinator.inventory_units).to eq inventory_units
      end
    end
  end

  describe "#stock_locations_for" do
    let(:order) { create(:order) }
    let!(:active_stock_location) { create(:stock_location, active: true) }
    let!(:inactive_stock_location) { create(:stock_location, active: false) }

    subject { stock_configuration.stock_locations_for(order) }

    it "excludes inactive stock locations" do
      is_expected.to include(active_stock_location)
      is_expected.not_to include(inactive_stock_location)
    end

    it "uses the configured stock location filter and sorter" do
      expect(stock_configuration).to receive(:location_filter_class).and_call_original
      expect(stock_configuration).to receive(:location_sorter_class).and_call_original
      subject
    end
  end
end
