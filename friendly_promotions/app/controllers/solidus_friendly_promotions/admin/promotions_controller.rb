# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionsController < ::Spree::Admin::ResourceController
      before_action :load_data

      private

      def collection
        return @collection if @collection
        params[:q] ||= HashWithIndifferentAccess.new
        params[:q][:s] ||= 'id desc'

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result(distinct: true).
          includes(promotion_includes).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:promotions_per_page])

        @collection
      end

      def promotion_includes
        [:promotion_actions]
      end

      def load_data
        @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
        @promotion_categories = Spree::PromotionCategory.order(:name)
      end
    end
  end
end
