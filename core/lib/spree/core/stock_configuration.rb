# frozen_string_literal: true

module Spree
  module Core
    class StockConfiguration < Spree::Preferences::Configuration
      class_name_attribute :coordinator_class, default: "::Spree::Stock::SimpleCoordinator"
      class_name_attribute :estimator_class, default: "::Spree::Stock::Estimator"
      class_name_attribute :location_filter_class, default: "::Spree::Stock::LocationFilter::Active"
      class_name_attribute :location_sorter_class, default: "::Spree::Stock::LocationSorter::Unsorted"
      class_name_attribute :allocator_class, default: "::Spree::Stock::Allocator::OnHandFirst"
      class_name_attribute :inventory_unit_builder_class, default: "::Spree::Stock::InventoryUnitBuilder"
      class_name_attribute :availability_validator_class, default: "::Spree::Stock::AvailabilityValidator"
      class_name_attribute :inventory_validator_class, default: "::Spree::Stock::InventoryValidator"
    end
  end
end
