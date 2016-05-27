module Spree
  module Core
    class Environment
      include EnvironmentExtension

      add_class_set :payment_methods
      add_class_set :stock_splitters

      attr_accessor :calculators, :preferences, :promotions

      def initialize
        @calculators = Calculators.new
        @preferences = Spree::AppConfiguration.new
        @promotions = Spree::Promo::Environment.new
      end
    end
  end
end
