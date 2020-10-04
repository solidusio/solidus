# frozen_string_literal: true

require 'spree/core/environment_extension'

module Spree
  module Core
    class Environment
      include EnvironmentExtension

      add_class_set :payment_methods
      add_class_set :stock_splitters

      attr_accessor :calculators, :preferences, :promotions

      def initialize(spree_config)
        @calculators = Calculators.new
        @preferences = spree_config
        @promotions = Promotions.new
      end
    end
  end
end
