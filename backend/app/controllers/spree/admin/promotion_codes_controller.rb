# frozen_string_literal: true

require 'csv'

module Spree
  module Admin
    class PromotionCodesController < Spree::Admin::ResourceController
      before_action :load_promotion
      before_action :set_breadcrumbs

      def index
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
        @promotion_code = @promotion.promotion_codes.build
      end

      def create
        @promotion_code = @promotion.promotion_codes.build(value: params[:promotion_code][:value])

        if @promotion_code.save
          flash[:success] = flash_message_for(@promotion_code, :successfully_created)
          redirect_to admin_promotion_promotion_codes_url(@promotion)
        else
          flash.now[:error] = @promotion_code.errors.full_messages.to_sentence
          render_after_create_error
        end
      end

      private

      def load_promotion
        @promotion = Spree::Promotion.accessible_by(current_ability, :read).find(params[:promotion_id])
      end

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Promotion), spree.admin_promotions_path
        add_breadcrumb @promotion.name, spree.edit_admin_promotion_path(@promotion)
        add_breadcrumb plural_resource_name(Spree::PromotionCode)
      end
    end
  end
end
