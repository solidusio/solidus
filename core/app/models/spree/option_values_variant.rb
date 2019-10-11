# frozen_string_literal: true

module Solidus
  class OptionValuesVariant < Solidus::Base
    belongs_to :variant, optional: true
    belongs_to :option_value, optional: true
  end
end
