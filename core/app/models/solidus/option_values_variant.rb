module Spree
  class OptionValuesVariant < Spree::Base
    belongs_to :variant
    belongs_to :option_value
  end
end
