# frozen_string_literal: true

module Solidus
  class ProductOptionType < Solidus::Base
    belongs_to :product, class_name: 'Solidus::Product', inverse_of: :product_option_types, touch: true, optional: true
    belongs_to :option_type, class_name: 'Solidus::OptionType', inverse_of: :product_option_types, optional: true
    acts_as_list scope: :product
  end
end
