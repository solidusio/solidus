# frozen_string_literal: true

module Spree
  class ShippingMethodZone < Spree::Base
    belongs_to :zone, optional: true
    belongs_to :shipping_method, optional: true
  end
end
