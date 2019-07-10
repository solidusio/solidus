# frozen_string_literal: true

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
    belongs_to :product, touch: true, optional: true

    has_many :values, class_name: 'Spree::VariantPropertyRuleValue', dependent: :destroy
    has_many :properties, through: :values
    has_many :conditions, class_name: 'Spree::VariantPropertyRuleCondition', dependent: :destroy
    has_many :option_values, through: :conditions

    accepts_nested_attributes_for :values, allow_destroy: true, reject_if: lambda { |val| val[:property_name].blank? }

    # Checks whether the provided ids are the same as the rule's
    # condition's option value ids.
    #
    # @param option_value_ids [Array<Integer>] list of option value ids
    # @return [Boolean]
    def matches_option_value_ids?(option_value_ids)
      self.option_value_ids.sort == option_value_ids.sort
    end

    # Checks whether the rule applies to the variant by
    # checking the rule's conditions against the variant's
    # option values.
    #
    # @param variant [Spree::Variant] variant to check
    # @return [Boolean]
    def applies_to_variant?(variant)
      (option_value_ids & variant.option_value_ids).present?
    end
  end
end
