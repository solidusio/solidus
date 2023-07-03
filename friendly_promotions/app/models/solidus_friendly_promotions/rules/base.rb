# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class Base < Spree::PromotionRule
      def to_partial_path
        "solidus_friendly_promotions/admin/promotion_rules/rules/#{model_name.element}"
      end
    end
  end
end
