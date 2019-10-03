# frozen_string_literal: true

# Default class for deciding what the current store is, given an HTTP request
# This is an extension point used in Solidus::Core::ControllerHelpers::Store
# Custom versions of this class must respond to a store instance method
module Solidus
  module Core
    class CurrentStore
      def initialize(request)
        @request = request
        @current_store_selector = Solidus::Config.current_store_selector_class.new(request)
        Solidus::Deprecation.warn "Using Solidus::Core::CurrentStore is deprecated. Use Solidus::Config.current_store_selector_class instead", caller
      end

      # Delegate store selection to Solidus::Config.current_store_selector_class
      # Using this class is deprecated.
      #
      # @return [Solidus::Store]
      def store
        @current_store_selector.store
      end
    end
  end
end
