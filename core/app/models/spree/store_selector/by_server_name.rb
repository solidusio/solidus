# frozen_string_literal: true

# Default implementation for finding the current store is given an HTTP request
#
# This is the new default behaviour, starting in Solidus 2.3.0. For the old
# behaviour see Spree::StoreSelector::Legacy.
#
# This attempts to find a Spree::Store with a URL matching the domain name of
# the request exactly. Failing that it will return the store marked as default.
module Spree
  module StoreSelector
    class ByServerName
      def initialize(request)
        @request = request
      end

      # Chooses the current store based on a request.
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
end
