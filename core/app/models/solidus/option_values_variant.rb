module Solidus
  class OptionValuesVariant < Solidus::Base
    belongs_to :variant
    belongs_to :option_value
  end
end
