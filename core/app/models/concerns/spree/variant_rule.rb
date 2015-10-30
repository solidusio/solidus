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
