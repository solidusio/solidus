module Spree
  module Core
    class Environment
      include EnvironmentExtension

      attr_accessor :calculators, :payment_methods, :preferences,
                    :stock_splitters

      def initialize
        @calculators = Calculators.new
        @preferences = Solidus::AppConfiguration.new
      end
    end
  end
end
