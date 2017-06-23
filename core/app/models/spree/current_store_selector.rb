# Default class for deciding what the current store is, given an HTTP request
# This is an extension point used in Spree::Core::ControllerHelpers::Store
# Custom versions of this class must respond to a store instance method
module Spree
  class CurrentStoreSelector
    def initialize(request)
      @request = request
    end

    # Chooses the current store based on a request.
    # Checks request headers for HTTP_SPREE_STORE and falls back to
    # looking up by the requesting server's name.
    # @return [Spree::Store]
    def store
      server_name = @request.env['SERVER_NAME']

      # We select a store which either matches our server name, or is default.
      # We sort by `default ASC` so that a store matching SERVER_NAME will come
      # first, and we will find that instead of the default.
      store = Spree::Store.where(url: server_name).or(Store.where(default: true)).order(default: :asc).first

      # Provide a fallback, mostly for legacy/testing purposes
      store || Spree::Store.new
    end
  end
end
