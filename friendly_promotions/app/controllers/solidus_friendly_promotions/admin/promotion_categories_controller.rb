# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionCategoriesController < Spree::Admin::ResourceController
      private

      def model_class
        SolidusFriendlyPromotions::PromotionCategory
      end

      def routes_proxy
        solidus_friendly_promotions
      end
    end
  end
end
