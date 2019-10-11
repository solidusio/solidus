# frozen_string_literal: true

module Solidus
  class StoreShippingMethod < Solidus::Base
    belongs_to :store, inverse_of: :store_shipping_methods, optional: true
    belongs_to :shipping_method, inverse_of: :store_shipping_methods, optional: true
  end
end
