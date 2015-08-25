module Spree
  class ShippingMethodZone < Spree::Base
    belongs_to :zone
    belongs_to :shipping_method
  end
end
