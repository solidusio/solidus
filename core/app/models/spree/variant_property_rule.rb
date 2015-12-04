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
