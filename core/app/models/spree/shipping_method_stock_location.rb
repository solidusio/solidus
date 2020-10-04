# frozen_string_literal: true

class Spree::ShippingMethodStockLocation < Spree::Base
  belongs_to :shipping_method, optional: true
  belongs_to :stock_location, optional: true
end
