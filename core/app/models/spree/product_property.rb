# frozen_string_literal: true

module Spree
  class ProductProperty < Spree::Base
    include Spree::OrderedPropertyValueList

    acts_as_list scope: :product

    belongs_to :product, touch: true, class_name: 'Spree::Product', inverse_of: :product_properties, optional: true
    belongs_to :property, class_name: 'Spree::Property', inverse_of: :product_properties, optional: true

    self.whitelisted_ransackable_attributes = ['value']
  end
end
