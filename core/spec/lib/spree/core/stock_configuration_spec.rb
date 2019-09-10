# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::StockConfiguration do
  describe '#coordinator_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.coordinator_class }

    it "returns Spree::Stock::Coordinator" do
      is_expected.to be ::Spree::Stock::SimpleCoordinator
    end

    context "with another constant name assiged" do
      MyCoordinator = Class.new
      before { stock_configuration.coordinator_class = MyCoordinator.to_s }

      it "returns the constant" do
        is_expected.to be MyCoordinator
      end
    end
  end

  describe '#estimator_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.estimator_class }

    it "returns Spree::Stock::Estimator" do
      is_expected.to be ::Spree::Stock::Estimator
    end

    context "with another constant name assiged" do
      MyEstimator = Class.new
      before { stock_configuration.estimator_class = MyEstimator.to_s }

      it "returns the constant" do
        is_expected.to be MyEstimator
      end
    end
  end

  describe '#location_filter_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.location_filter_class }

    it "returns Spree::Stock::LocationFilter::Active" do
      is_expected.to be ::Spree::Stock::LocationFilter::Active
    end

    context "with another constant name assiged" do
      MyFilter = Class.new
      before { stock_configuration.location_filter_class = MyFilter.to_s }

      it "returns the constant" do
        is_expected.to be MyFilter
      end
    end
  end

  describe '#location_sorter_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.location_sorter_class }

    it "returns Spree::Stock::LocationSorter::Unsorted" do
      is_expected.to be ::Spree::Stock::LocationSorter::Unsorted
    end

    context "with another constant name assiged" do
      MySorter = Class.new
      before { stock_configuration.location_sorter_class = MySorter.to_s }

      it "returns the constant" do
        is_expected.to be MySorter
      end
    end
  end

  describe '#allocator_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.allocator_class }

    it "returns Spree::Stock::Allocator::OnHandFirst" do
      is_expected.to be ::Spree::Stock::Allocator::OnHandFirst
    end

    context "with another constant name assiged" do
      MyAllocator = Class.new
      before { stock_configuration.allocator_class = MyAllocator.to_s }

      it "returns the constant" do
        is_expected.to be MyAllocator
      end
    end
  end
end
