# frozen_string_literal: true

module Spree
  class ProductOptionType < Spree::Base
    belongs_to :product, class_name: 'Spree::Product', inverse_of: :product_option_types, touch: true
    belongs_to :option_type, class_name: 'Spree::OptionType', inverse_of: :product_option_types
    acts_as_list scope: :product

    delegate :name, :presentation, :option_values, to: :option_type
  end
end
