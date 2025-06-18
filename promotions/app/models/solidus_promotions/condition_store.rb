# frozen_string_literal: true

module SolidusPromotions
  class ConditionStore < Spree::Base
    belongs_to :condition, class_name: "SolidusPromotions::Condition"
    belongs_to :store, class_name: "Spree::Store"
  end
end
