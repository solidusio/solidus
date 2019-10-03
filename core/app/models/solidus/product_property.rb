# frozen_string_literal: true

module Solidus
  class ProductProperty < Solidus::Base
    include Solidus::OrderedPropertyValueList

    acts_as_list scope: :product

    belongs_to :product, touch: true, class_name: 'Solidus::Product', inverse_of: :product_properties, optional: true
    belongs_to :property, class_name: 'Solidus::Property', inverse_of: :product_properties, optional: true

    self.whitelisted_ransackable_attributes = ['value']
  end
end
