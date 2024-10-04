# frozen_string_literal: true

module SolidusPromotions
  class ConditionTaxon < Spree::Base
    belongs_to :condition, class_name: "SolidusPromotions::Condition", optional: true
    belongs_to :taxon, class_name: "Spree::Taxon", optional: true
  end
end
