# frozen_string_literal: true

module Spree
  class Promotion
    module Rules
      class Store < PromotionRule
        has_many :promotion_rule_stores, class_name: "Spree::PromotionRuleStore",
                                         foreign_key: :promotion_rule_id,
                                         dependent: :destroy
        has_many :stores, through: :promotion_rule_stores, class_name: "Spree::Store"

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          stores.none? || stores.include?(order.store)
        end
      end
    end
  end
end
