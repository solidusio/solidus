module Spree
  class ProductProperty < Spree::Base
    include Spree::OrderedPropertyValueList

    belongs_to :product, touch: true, class_name: 'Spree::Product', inverse_of: :product_properties
    belongs_to :property, class_name: 'Spree::Property', inverse_of: :product_properties

    self.whitelisted_ransackable_attributes = ['value']
  end
end
