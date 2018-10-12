# frozen_string_literal: true

module Spree
  module Core
    class StockConfiguration
      attr_writer :coordinator_class, :estimator_class, :allocator_class

      def coordinator_class
        @coordinator_class ||= '::Spree::Stock::SimpleCoordinator'
        @coordinator_class.constantize
      end

      def estimator_class
        @estimator_class ||= '::Spree::Stock::Estimator'
        @estimator_class.constantize
      end

      def allocator_class
        @allocator_class ||= '::Spree::Stock::Allocator::OnHandFirst'
        @allocator_class.constantize
      end
    end
  end
end
