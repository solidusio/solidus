module Spree
  # Option types denote the different options for a variant. A typical option
  # type would be a size, with that option type’s values being something such
  # as "Small", "Medium" and "Large". Another typical option type could be a
  # color, such as "Red", "Green", or "Blue".
  #
  # A product can be assigned many option types, but must be assigned at least
  # one if you wish to create variants for that product.
  class OptionType < Spree::Base
    acts_as_list

    has_many :option_values, -> { order(:position) }, dependent: :destroy, inverse_of: :option_type
    has_many :product_option_types, dependent: :destroy, inverse_of: :option_type
    has_many :products, through: :product_option_types
    has_and_belongs_to_many :prototypes, join_table: 'spree_option_types_prototypes'

    validates :name, presence: true, uniqueness: true
    validates :presentation, presence: true

    default_scope -> { order("#{self.table_name}.position") }

    accepts_nested_attributes_for :option_values, reject_if: lambda { |ov| ov[:name].blank? || ov[:presentation].blank? }, allow_destroy: true

    after_touch :touch_all_products

    def touch_all_products
      products.update_all(updated_at: Time.current)
    end
  end
end
