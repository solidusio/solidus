module Spree
  class ShippingMethodZone < Spree::Base
    self.table_name = 'spree_shipping_methods_zones'

    belongs_to :zone
    belongs_to :shipping_method
  end
end
