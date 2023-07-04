# frozen_string_literal: true

module SolidusFriendlyPromotions
  class RulesTaxon < Spree::Base
    belongs_to :rule
    belongs_to :taxon, class_name: "Spree::Taxon"
  end
end
