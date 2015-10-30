# The reason for variant properties not being associated with variants
# (either directly or through an association table) is performance.
#
# Variant properties are intended to be applied to a group of variants based
# on their option values. If there were thousands of variants that shared the
# same option value, attempting to associate a variant property with that
# group of variants would be problematic in terms of performance.
#
# An added benefit to this approach is not having to associate existing variant
# properties with newly created variants. If the variant has the option values
# targeted by the rule, the properties will automatically apply to the variant.
module Spree
  class VariantPropertyRule < Spree::Base
    include Spree::VariantRule

    has_many :values, class_name: 'Spree::VariantPropertyRuleValue', dependent: :destroy
    has_many :properties, through: :values
    has_many :conditions, class_name: 'Spree::VariantPropertyRuleCondition', dependent: :destroy

    accepts_nested_attributes_for :values, allow_destroy: true, reject_if: lambda { |val| val[:property_name].blank? }

    # Checks whether the rule applies to the variant by
    # checking the rule's conditions against the variant's
    # option values.
    #
    # @param variant [Spree::Variant] variant to check
    # @return [Boolean]
    def applies_to_variant?(variant)
      applies_to_option_value_ids?(variant.option_value_ids)
    end
  end
end
