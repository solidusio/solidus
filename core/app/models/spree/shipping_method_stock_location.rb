class Spree::ShippingMethodStockLocation < Spree::Base
  belongs_to :shipping_method
  belongs_to :stock_location
end
