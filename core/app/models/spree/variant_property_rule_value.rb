# frozen_string_literal: true

module Solidus
  class VariantPropertyRuleValue < Solidus::Base
    include Solidus::OrderedPropertyValueList

    acts_as_list scope: :variant_property_rule

    belongs_to :property, optional: true
    belongs_to :variant_property_rule, touch: true, optional: true
  end
end
