# frozen_string_literal: true

module Spree
  class ShippingMethodCategory < Spree::Base
    belongs_to :shipping_method, class_name: 'Spree::ShippingMethod', optional: true
    belongs_to :shipping_category, class_name: 'Spree::ShippingCategory', inverse_of: :shipping_method_categories, optional: true
  end
end
