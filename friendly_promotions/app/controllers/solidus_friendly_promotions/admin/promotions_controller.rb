# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionsController < BaseController
      before_action :load_data

      helper "solidus_friendly_promotions/admin/promotion_rules"
      helper "solidus_friendly_promotions/admin/promotion_actions"

      def create
        @promotion = model_class.new(permitted_resource_params)
        @promotion.codes.new(value: params[:single_code]) if params[:single_code].present?

        if params[:code_batch]
          @code_batch = @promotion.code_batches.new(code_batch_params)
        end

        if @promotion.save
          @code_batch&.process
          flash[:success] = t("solidus_friendly_promotions.promotion_successfully_created")
          redirect_to location_after_save
        else
          flash[:error] = @promotion.errors.full_messages.to_sentence
          render action: "new"
        end
      end

      private

      def collection
        return @collection if @collection

        params[:q] ||= HashWithIndifferentAccess.new
        params[:q][:s] ||= "updated_at desc"

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result(distinct: true)
          .includes(promotion_includes)
          .page(params[:page])
          .per(params[:per_page] || SolidusFriendlyPromotions.config.promotions_per_page)

        @collection
      end

      def promotion_includes
        [:actions]
      end

      def model_class
        SolidusFriendlyPromotions::Promotion
      end

      def load_data
        @promotion_categories = PromotionCategory.order(:name)
      end

      def location_after_save
        solidus_friendly_promotions.edit_admin_promotion_url(@promotion)
      end
    end
  end
end
