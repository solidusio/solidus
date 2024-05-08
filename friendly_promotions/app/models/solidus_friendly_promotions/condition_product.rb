# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ConditionProduct < Spree::Base
    belongs_to :condition, class_name: "SolidusFriendlyPromotions::Condition", optional: true
    belongs_to :product, class_name: "Spree::Product", optional: true
  end
end
