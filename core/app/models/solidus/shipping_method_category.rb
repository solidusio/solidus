# frozen_string_literal: true

module Solidus
  class ShippingMethodCategory < Solidus::Base
    belongs_to :shipping_method, class_name: 'Solidus::ShippingMethod', optional: true
    belongs_to :shipping_category, class_name: 'Solidus::ShippingCategory', inverse_of: :shipping_method_categories, optional: true
  end
end
