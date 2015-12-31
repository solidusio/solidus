module Spree
  class ProductProperty < Solidus::Base
    include Solidus::OrderedPropertyValueList

    belongs_to :product, touch: true, class_name: 'Solidus::Product', inverse_of: :product_properties
    belongs_to :property, class_name: 'Solidus::Property', inverse_of: :product_properties

    self.whitelisted_ransackable_attributes = ['value']
  end
end
