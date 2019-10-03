# frozen_string_literal: true

module Solidus
  class PromotionRuleStore < Solidus::Base
    self.table_name = "spree_promotion_rules_stores"

    belongs_to :promotion_rule, class_name: "Solidus::PromotionRule", optional: true
    belongs_to :store, class_name: "Solidus::Store", optional: true
  end
end
