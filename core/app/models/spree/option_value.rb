module Spree
  class OptionValue < Spree::Base
    belongs_to :option_type, class_name: 'Spree::OptionType', touch: true, inverse_of: :option_values
    acts_as_list scope: :option_type

    has_many :option_values_variants
    has_many :variants, through: :option_values_variants

    validates :name, presence: true, uniqueness: { scope: :option_type_id }
    validates :presentation, presence: true

    after_touch :touch_all_variants

    # Updates the updated_at column on all the variants associated with this
    # option value.
    def touch_all_variants
      variants.update_all(updated_at: Time.current)
    end

    # @return [String] a string representation of all option value and its
    #   option type
    def presentation_with_option_type
      "#{self.option_type.presentation} - #{self.presentation}"
    end
  end
end
