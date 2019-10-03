# frozen_string_literal: true

module Solidus
  class ShippingCategory < Solidus::Base
    validates :name, presence: true
    has_many :products, inverse_of: :shipping_category
    has_many :shipping_method_categories, inverse_of: :shipping_category
    has_many :shipping_methods, through: :shipping_method_categories
  end
end
