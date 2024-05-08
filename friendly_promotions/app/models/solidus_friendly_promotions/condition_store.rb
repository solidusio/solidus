# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ConditionStore < Spree::Base
    belongs_to :condition, class_name: "SolidusFriendlyPromotions::Condition", optional: true
    belongs_to :store, class_name: "Spree::Store", optional: true
  end
end
