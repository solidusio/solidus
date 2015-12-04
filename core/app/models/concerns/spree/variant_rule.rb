# Variant rules are useful when there is common data intended to be applied
# to a group of variants based on their option values. If there were thousands
# of variants that share the same option value, attempting to associate data
# with that group of variants would be problematic in terms of performance.
#
# Besides performance benefits, an added advantage to this approach is not having
# to associate existing data with newly created variants. If the variant has the
# option values targeted by the rule, the data will automatically apply to the variant.
module Spree::VariantRule
  extend ActiveSupport::Concern

  included do
    belongs_to :product, touch: true
    has_many :option_values, through: :conditions
  end

  # Checks whether the provided ids are the same as the rule's
  # condition's option value ids.
  #
  # @param option_value_ids [Array<Integer>] list of option value ids
  # @return [Boolean]
  def matches_option_value_ids?(option_value_ids)
    self.option_value_ids.sort == option_value_ids.sort
  end

  # Checks if the provided list of option value ids contains
  # all of the rule's option values.
  #
  # @param option_value_ids [Array<Integer>] list of option value ids
  # @return [Boolean]
  def applies_to_option_value_ids?(option_value_ids)
    (self.option_value_ids - option_value_ids).empty?
  end
end
