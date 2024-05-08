# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ConditionTaxon < Spree::Base
    belongs_to :condition, class_name: "SolidusFriendlyPromotions::Condition", optional: true
    belongs_to :taxon, class_name: "Spree::Taxon", optional: true
  end
end
