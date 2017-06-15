# Default class for deciding what the current store is, given an HTTP request
#
# To use a custom version of this class just set the preference:
#   Spree::Config.current_store_selector_class = CustomCurrentStoreSelector
#
# Custom versions of this class must respond to a store instance method
module Spree
  class CurrentStoreSelector
    def initialize(request)
      @request = request
    end

    # Select the store to be used. In this basic implementation the
    # default store will be always selected.
    #
    # @return [Spree::Store]
    def store
      Spree::Store.default
    end
  end
end
