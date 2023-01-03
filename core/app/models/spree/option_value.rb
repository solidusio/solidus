# frozen_string_literal: true

module Spree
  class OptionValue < Spree::Base
    # TODO: Remove optional on Solidus v4.0. Don't forget adding a migration to
    # enforce at the database layer
    belongs_to :option_type, class_name: 'Spree::OptionType', inverse_of: :option_values, optional: true
    acts_as_list scope: :option_type

    has_many :option_values_variants, dependent: :destroy
    has_many :variants, through: :option_values_variants

    validates :name, presence: true, uniqueness: { scope: :option_type_id, allow_blank: true, case_sensitive: true }
    validates :presentation, presence: true

    after_save :touch, if: :saved_changes?
    after_touch :touch_all_variants
    after_save do
      Spree::Deprecation.warn <<~MSG if option_type.nil?
        Having an option_value with no associated option_type will be deprecated
        on Solidus v4.0
      MSG
    end

    # TODO: Remove allow_nil once option_type is required on Solidus v4.0
    delegate :name, :presentation, to: :option_type, prefix: :option_type, allow_nil: true

    self.whitelisted_ransackable_attributes = %w[name presentation]

    # Updates the updated_at column on all the variants associated with this
    # option value.
    def touch_all_variants
      variants.find_each(&:touch)
    end

    # @return [String] a string representation of all option value and its
    #   option type
    def presentation_with_option_type
      "#{option_type.presentation} - #{presentation}"
    end
  end
end

