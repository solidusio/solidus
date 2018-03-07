# frozen_string_literal: true

module Spree
  class StoreShippingMethod < Spree::Base
    belongs_to :store, inverse_of: :store_shipping_methods
    belongs_to :shipping_method, inverse_of: :store_shipping_methods
  end
end
