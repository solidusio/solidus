# frozen_string_literal: true

module Spree
  class ShippingCategory < Spree::Base
    self.allowed_ransackable_attributes = %w[name]

    validates :name, presence: true
    has_many :products, inverse_of: :shipping_category, dependent: :restrict_with_error
    has_many :shipping_method_categories, inverse_of: :shipping_category, dependent: :destroy
    has_many :shipping_methods, through: :shipping_method_categories
  end
end
