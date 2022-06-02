# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::StockConfiguration do
  let(:stock_configuration) { described_class.new }

  describe '#coordinator_class' do
    subject { stock_configuration.coordinator_class }

    it "returns Spree::Stock::Coordinator by default" do
      expect(subject).to be ::Spree::Stock::SimpleCoordinator
    end

    it "can be reassigned" do
      MyCoordinator = Class.new
      stock_configuration.coordinator_class = MyCoordinator.to_s

      expect(subject).to be MyCoordinator

      Object.send(:remove_const, :MyCoordinator)
    end
  end

  describe '#estimator_class' do
    subject { stock_configuration.estimator_class }

    it "returns Spree::Stock::Estimator" do
      expect(subject).to be ::Spree::Stock::Estimator
    end

    it "can be reassigned" do
      MyEstimator = Class.new
      stock_configuration.estimator_class = MyEstimator.to_s

      expect(subject).to be MyEstimator

      Object.send(:remove_const, :MyEstimator)
    end
  end

  describe '#location_filter_class' do
    subject { stock_configuration.location_filter_class }

    it "returns Spree::Stock::LocationFilter::Active by default" do
      expect(subject).to be ::Spree::Stock::LocationFilter::Active
    end

    it "can be reassigned" do
      MyFilter = Class.new
      stock_configuration.location_filter_class = MyFilter.to_s

      expect(subject).to be MyFilter

      Object.send(:remove_const, :MyFilter)
    end
  end

  describe '#location_sorter_class' do
    subject { stock_configuration.location_sorter_class }

    it "returns Spree::Stock::LocationSorter::Unsorted by default" do
      expect(subject).to be ::Spree::Stock::LocationSorter::Unsorted
    end

    it "can be reassigned" do
      MySorter = Class.new
      stock_configuration.location_sorter_class = MySorter.to_s

      expect(subject).to be MySorter

      Object.send(:remove_const, :MySorter)
    end
  end

  describe '#allocator_class' do
    subject { stock_configuration.allocator_class }

    it "returns Spree::Stock::Allocator::OnHandFirst by default" do
      expect(subject).to be ::Spree::Stock::Allocator::OnHandFirst
    end

    it "can be reassigned" do
      MyAllocator = Class.new
      stock_configuration.allocator_class = MyAllocator.to_s

      expect(subject).to be MyAllocator

      Object.send(:remove_const, :MyAllocator)
    end
  end

  describe '#inventory_unit_builder_class' do
    subject { stock_configuration.inventory_unit_builder_class }

    it "returns Spree::Stock::InventoryUnitBuilder by default" do
      expect(subject).to be ::Spree::Stock::InventoryUnitBuilder
    end

    it "can be reassigned" do
      MyInventoryUnitBuilder = Class.new
      stock_configuration.inventory_unit_builder_class = MyInventoryUnitBuilder.to_s

      expect(subject).to be MyInventoryUnitBuilder

      Object.send(:remove_const, :MyInventoryUnitBuilder)
    end
  end

  describe '#availability_validator_class' do
    subject { stock_configuration.availability_validator_class }

    let(:stock_configuration) { described_class.new }

    it "returns Spree::Stock::AvailabilityValidator" do
      is_expected.to be ::Spree::Stock::AvailabilityValidator
    end

    it "can be reassigned" do
      MyAvailabilityValidator = Class.new
      stock_configuration.availability_validator_class = MyAvailabilityValidator.to_s

      expect(subject).to be MyAvailabilityValidator

      Object.send(:remove_const, :MyAvailabilityValidator)
    end
  end

  describe '#inventory_validator_class' do
    subject { stock_configuration.inventory_validator_class }

    let(:stock_configuration) { described_class.new }

    it "returns Spree::Stock::InventoryValidator" do
      is_expected.to be ::Spree::Stock::InventoryValidator
    end

    it "can be reassigned" do
      MyInventoryValidator = Class.new
      stock_configuration.inventory_validator_class = MyInventoryValidator.to_s

      expect(subject).to be MyInventoryValidator

      Object.send(:remove_const, :MyInventoryValidator)
    end
  end
end
