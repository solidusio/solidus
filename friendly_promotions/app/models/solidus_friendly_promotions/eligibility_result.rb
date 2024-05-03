# frozen_string_literal: true

module SolidusFriendlyPromotions
  EligibilityResult = Struct.new(:item, :condition, :success, :code, :message, keyword_init: true)
end
