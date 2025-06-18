# frozen_string_literal: true

module SolidusPromotions
  class ConditionProduct < Spree::Base
    belongs_to :condition, class_name: "SolidusPromotions::Condition"
    belongs_to :product, class_name: "Spree::Product"
  end
end
