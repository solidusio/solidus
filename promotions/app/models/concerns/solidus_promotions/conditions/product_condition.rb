# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module ProductCondition
      def self.included(base)
        base.has_many :condition_products,
          dependent: :destroy,
          foreign_key: :condition_id,
          class_name: "SolidusPromotions::ConditionProduct",
          inverse_of: :condition
        base.has_many :products, class_name: "Spree::Product", through: :condition_products
      end

      def preload_relations
        [:products]
      end

      def product_ids_string
        product_ids.join(",")
      end

      def product_ids_string=(product_ids)
        self.product_ids = product_ids.to_s.split(",").map(&:strip)
      end
    end
  end
end
