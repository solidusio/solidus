# frozen_string_literal: true

module Solidus
  class ShippingMethodZone < Solidus::Base
    belongs_to :zone, optional: true
    belongs_to :shipping_method, optional: true
  end
end
