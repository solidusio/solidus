# frozen_string_literal: true

module SolidusFriendlyPromotions
  class RulesStore < Spree::Base
    belongs_to :rule
    belongs_to :store, class_name: "Spree::Store"
  end
end
