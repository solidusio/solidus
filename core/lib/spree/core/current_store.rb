# frozen_string_literal: true

# Default class for deciding what the current store is, given an HTTP request
# This is an extension point used in Spree::Core::ControllerHelpers::Store
# Custom versions of this class must respond to a store instance method
module Spree
  module Core
    class CurrentStore
      def initialize(request)
        @request = request
        @current_store_selector = Spree::Config.current_store_selector_class.new(request)
        Spree::Deprecation.warn "Using Spree::Core::CurrentStore is deprecated. Use Spree::Config.current_store_selector_class instead", caller
      end

      # Delegate store selection to Spree::Config.current_store_selector_class
      # Using this class is deprecated.
      #
      # @return [Spree::Store]
      def store
        @current_store_selector.store
      end
    end
  end
end
