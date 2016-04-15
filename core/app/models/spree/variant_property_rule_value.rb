module Spree
  class VariantPropertyRuleValue < Spree::Base
    include Spree::OrderedPropertyValueList

    acts_as_list scope: :variant_property_rule

    belongs_to :property
    belongs_to :variant_property_rule, touch: true
  end
end
