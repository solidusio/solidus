# frozen_string_literal: true

require 'csv'

module Spree
  module Admin
    class PromotionCodesController < Spree::Admin::ResourceController
      def index
        @promotion = Spree::Promotion.accessible_by(current_ability, :read).find(params[:promotion_id])
        @promotion_codes = @promotion.promotion_codes.order(:value)

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
        @promotion = Spree::Promotion.accessible_by(current_ability, :read).find(params[:promotion_id])
        if @promotion.apply_automatically
          flash[:error] = t('activerecord.errors.models.spree/promotion_code.attributes.base.disallowed_with_apply_automatically')
          redirect_to admin_promotion_promotion_codes_url(@promotion)
        else
          @promotion_code = @promotion.promotion_codes.build
        end
      end

      def create
        @promotion = Spree::Promotion.accessible_by(current_ability, :read).find(params[:promotion_id])
        @promotion_code = @promotion.promotion_codes.build(value: params[:promotion_code][:value])

        if @promotion_code.save
          flash[:success] = flash_message_for(@promotion_code, :successfully_created)
          redirect_to admin_promotion_promotion_codes_url(@promotion)
        else
          flash.now[:error] = @promotion_code.errors.full_messages.to_sentence
          render_after_create_error
        end
      end
    end
  end
end
