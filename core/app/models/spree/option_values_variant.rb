# frozen_string_literal: true

module Spree
  class OptionValuesVariant < Spree::Base
    belongs_to :variant, optional: true
    belongs_to :option_value, optional: true
  end
end
