# frozen_string_literal: true

module SolidusPromotions
  class ConditionStore < Spree::Base
    belongs_to :condition, class_name: "SolidusPromotions::Condition", optional: true
    belongs_to :store, class_name: "Spree::Store", optional: true
  end
end
