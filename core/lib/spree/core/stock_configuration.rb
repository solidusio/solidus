module Spree
  module StockConfiguration
    mattr_accessor :estimator_class do
      '::Spree::Stock::Estimator'
    end

    def self.estimator_class
      @@estimator_class.constantize
    end
  end
end
