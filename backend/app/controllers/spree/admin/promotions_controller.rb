# frozen_string_literal: true

module Spree
  module Admin
    class PromotionsController < ResourceController
      before_action :load_data

      helper 'spree/promotion_rules'

      def show
        redirect_to action: :edit
      end

      def create
        @promotion = Spree::Promotion.new(permitted_resource_params)
        @promotion.codes.new(value: params[:single_code]) if params[:single_code].present?

        if params[:promotion_code_batch]
          @promotion_code_batch = @promotion.promotion_code_batches.new(promotion_code_batch_params)
        end

        if @promotion.save
          @promotion_code_batch.process if @promotion_code_batch
          flash[:success] = t('spree.promotion_successfully_created')
          redirect_to location_after_save
        else
          flash[:error] = @promotion.errors.full_messages.to_sentence
          render action: 'new'
        end
      end

      private

      def location_after_save
        spree.edit_admin_promotion_url(@promotion)
      end

      def load_data
        @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
        @promotion_categories = Spree::PromotionCategory.order(:name)
      end

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

      def promotion_code_batch_params
        params.require(:promotion_code_batch).permit!
      end

      def promotion_includes
        [:promotion_actions]
      end
    end
  end
end
