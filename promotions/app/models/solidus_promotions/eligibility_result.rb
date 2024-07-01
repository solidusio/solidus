# frozen_string_literal: true

module SolidusPromotions
  EligibilityResult = Struct.new(:item, :condition, :success, :code, :message, keyword_init: true)
end
