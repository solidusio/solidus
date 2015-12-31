module Spree
  class ShippingMethodCategory < Solidus::Base
    belongs_to :shipping_method, class_name: 'Solidus::ShippingMethod'
    belongs_to :shipping_category, class_name: 'Solidus::ShippingCategory', inverse_of: :shipping_method_categories
  end
end
