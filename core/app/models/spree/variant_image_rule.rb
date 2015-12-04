module Spree
  class VariantImageRule < Spree::Base
    include Spree::VariantRule

    has_many :values, class_name: 'Spree::VariantImageRuleValue', dependent: :destroy
    has_many :images, through: :values, class_name: 'Spree::Image'
    has_many :conditions, class_name: 'Spree::VariantImageRuleCondition', dependent: :destroy

    validates_presence_of :values

    accepts_nested_attributes_for :values, allow_destroy: true

    default_scope { includes(:option_values) }

    # Checks whether the rule applies to the variant by
    # checking the rule's conditions against the variant's
    # option values. When no conditions are associated with
    # the rule, it applies to all variants.
    #
    # @param variant [Spree::Variant] variant to check
    # @return [Boolean]
    def applies_to_variant?(variant)
      return true if self.option_value_ids.empty?
      applies_to_option_value_ids?(variant.option_value_ids)
    end
  end
end
