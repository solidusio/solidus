# frozen_string_literal: true

module Spree
  module Stock
    class ShipmentBuilder
      def initialize(
        packages:,
        estimator_class: Spree::Config.stock.estimator_class
      )
        @packages = packages
        @estimator = estimator_class.new
      end

      def call
        # Turn the Stock::Packages into a Shipment with rates
        @packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = @estimator.shipping_rates(package)
          shipment
        end
      end
    end
  end
end
