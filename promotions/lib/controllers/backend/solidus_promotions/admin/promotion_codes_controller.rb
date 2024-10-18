# frozen_string_literal: true

require "csv"

module SolidusPromotions
  module Admin
    class PromotionCodesController < BaseController
      before_action :load_promotion

      def index
        @promotion_codes = @promotion.codes.order(:value)

        respond_to do |format|
          format.html do
            @promotion_codes = @promotion_codes.page(params[:page]).per(50)
          end
          format.csv do
            filename = "promotion-code-list-#{@promotion.id}.csv"
            headers["Content-Type"] = "text/csv"
            headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
          end
        end
      end

      def new
        if @promotion.apply_automatically
          flash[:error] = t(
            :disallowed_with_apply_automatically,
            scope: "activerecord.errors.models.solidus_promotions/promotion_code.attributes.base"
          )
          redirect_to solidus_promotions.admin_promotion_promotion_codes_url(@promotion)
        else
          @promotion_code = @promotion.codes.build
        end
      end

      def create
        @promotion_code = @promotion.codes.build(value: params[:promotion_code][:value])

        if @promotion_code.save
          flash[:success] = flash_message_for(@promotion_code, :successfully_created)
          redirect_to solidus_promotions.admin_promotion_promotion_codes_url(@promotion)
        else
          flash.now[:error] = @promotion_code.errors.full_messages.to_sentence
          render_after_create_error
        end
      end

      private

      def load_promotion
        @promotion = SolidusPromotions::Promotion
          .accessible_by(current_ability, :show)
          .find(params[:promotion_id])
      end
    end
  end
end
