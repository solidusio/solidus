# Default class for deciding what the current store is, given an HTTP request
# This is an extension point used in Solidus::Core::ControllerHelpers::Store
# Custom versions of this class must respond to a store instance method
module Solidus
  module Core
    class CurrentStore
      def initialize(request)
        @request = request
      end

      # Chooses the current store based on a request.
      # Checks request headers for HTTP_SOLIDUS_STORE and falls back to
      # looking up by the requesting server's name.
      # @return [Solidus::Store]
      def store
        Solidus::Store.current(store_key)
      end

      private

      def store_key
        @request.headers['HTTP_SOLIDUS_STORE'] || @request.env['SERVER_NAME']
      end
    end
  end
end