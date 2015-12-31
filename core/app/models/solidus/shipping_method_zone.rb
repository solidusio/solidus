module Solidus
  class ShippingMethodZone < Solidus::Base
    belongs_to :zone
    belongs_to :shipping_method
  end
end
