module Solidus
  class VariantPropertyRuleValue < Solidus::Base
    include Solidus::OrderedPropertyValueList

    belongs_to :property
    belongs_to :variant_property_rule, touch: true
  end
end
