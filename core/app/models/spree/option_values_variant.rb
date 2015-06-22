module Spree
  class OptionValuesVariant < ActiveRecord::Base
    belongs_to :variant
    belongs_to :option_value
  end
end
