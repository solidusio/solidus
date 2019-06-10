# frozen_string_literal: true

require 'discard'

module Spree
  class ProductProperty < Spree::Base
    include Spree::OrderedPropertyValueList

    acts_as_list scope: :product

    include Discard::Model
    self.discard_column = :deleted_at

    belongs_to :product, -> { with_deleted }, touch: true, class_name: 'Spree::Product', inverse_of: :product_properties
    belongs_to :property, class_name: 'Spree::Property', inverse_of: :product_properties

    self.whitelisted_ransackable_attributes = ['value']
  end
end
