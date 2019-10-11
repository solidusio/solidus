# frozen_string_literal: true

class Solidus::ShippingMethodStockLocation < Solidus::Base
  belongs_to :shipping_method, optional: true
  belongs_to :stock_location, optional: true
end
