module Spree
  class VariantPropertyRuleValue < Spree::Base
    include Spree::OrderedPropertyValueList

    belongs_to :property
    belongs_to :variant_property_rule, touch: true
  end
end
