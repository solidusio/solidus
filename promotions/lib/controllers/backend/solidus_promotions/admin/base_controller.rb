# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class BaseController < Spree::Admin::ResourceController
      def routes_proxy
        solidus_promotions
      end

      def parent_model_name
        self.class.parent_data[:model_name].gsub("solidus_promotions/", "")
      end
    end
  end
end
