# frozen_string_literal: true

module Spree
  module Core
    class StockConfiguration
      attr_writer :coordinator_class
      attr_writer :estimator_class
      attr_writer :location_sorter_class

      def coordinator_class
        @coordinator_class ||= '::Spree::Stock::SimpleCoordinator'
        @coordinator_class.constantize
      end

      def estimator_class
        @estimator_class ||= '::Spree::Stock::Estimator'
        @estimator_class.constantize
      end

      def location_sorter_class
        @location_sorter_class ||= '::Spree::Stock::LocationSorter::Unsorted'
        @location_sorter_class.constantize
      end
    end
  end
end
