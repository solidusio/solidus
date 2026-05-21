# frozen_string_literal: true

module Spree
  module Core
    class StockConfiguration < Spree::Preferences::Configuration
      include Spree::Core::EnvironmentExtension

      class_name_attribute :coordinator_class, default: "::Spree::Stock::SimpleCoordinator"

      add_class_list :coordinator_middlewares, default: [
        "Spree::Stock::Middleware::InventoryUnit",
        "Spree::Stock::Middleware::InventoryUnitGroup",
        "Spree::Stock::Middleware::StockLocation",
        "Spree::Stock::Middleware::Allocate",
        "Spree::Stock::Middleware::Package",
        "Spree::Stock::Middleware::Shipment",
      ]
      class_name_attribute :estimator_class, default: "::Spree::Stock::Estimator"
      class_name_attribute :location_filter_class, default: "::Spree::Stock::LocationFilter::Active"
      class_name_attribute :location_sorter_class, default: "::Spree::Stock::LocationSorter::Unsorted"
      class_name_attribute :allocator_class, default: "::Spree::Stock::Allocator::OnHandFirst"
      class_name_attribute :inventory_unit_builder_class, default: "::Spree::Stock::InventoryUnitBuilder"
      class_name_attribute :availability_validator_class, default: "::Spree::Stock::AvailabilityValidator"
      class_name_attribute :inventory_validator_class, default: "::Spree::Stock::InventoryValidator"
      class_name_attribute :quantifier_class, default: "::Spree::Stock::Quantifier"
    end
  end
end
