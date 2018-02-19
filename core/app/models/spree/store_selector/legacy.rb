# frozen_string_literal: true

# This class provides the old behaviour for finding a matching Spree::Store
# based on a request.
#
# To enable this, somewhere inside config/initializers/ add
#
#     Spree::Config.current_store_selector_class = Spree::StoreSelector::Legacy
#
# This classes behaviour is somewhat complicated and has issues, which is why
# it has been replaced with Spree::StoreSelector::ByServerName by default.
#
# It will:
# * Find a "store_key"
#   * from the HTTP_SPREE_STORE header, if it exists
#   * or the server's domain name if HTTP_SPREE_STORE isn't set
# * Find a store, using the first match of:
#   * having a code matching the store_key exactly
#   * having a url which contains the store_key anywhere as a substring
#   * has default set to true
#
module Spree
  module StoreSelector
    class Legacy
      def initialize(request)
        @request = request
      end

      # Chooses the current store based on a request.
      # Checks request headers for HTTP_SPREE_STORE and falls back to
      # looking up by the requesting server's name.
      # @return [Spree::Store]
      def store
        current_store =
          if store_key
            Spree::Store.find_by(code: store_key) ||
              Store.where("url like ?", "%#{store_key}%").first
          end

        current_store || Spree::Store.default
      end

      private

      def store_key
        @request.headers['HTTP_SPREE_STORE'] || @request.env['SERVER_NAME']
      end
    end
  end
end
