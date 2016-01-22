module Spree
  module Core
    class StockConfiguration
      attr_writer :estimator_class

      def estimator_class
        @estimator_class ||= '::Spree::Stock::Estimator'
        @estimator_class.constantize
      end
    end
  end
end
