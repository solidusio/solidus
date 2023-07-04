# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class Store < Rule
      has_many :rules_stores, inverse_of: :rule, dependent: :destroy
      has_many :stores, through: :rules_stores, class_name: "Spree::Store"

      def preload_relations
        [:stores]
      end

      def applicable?(promotable)
        promotable.is_a?(Spree::Order)
      end

      def eligible?(order, _options = {})
        stores.none? || stores.include?(order.store)
      end
    end
  end
end
