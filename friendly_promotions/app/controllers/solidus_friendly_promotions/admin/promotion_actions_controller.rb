# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionActionsController < Spree::Admin::ResourceController
      before_action :load_promotion
      before_action :validate_promotion_action_type, only: [:create, :new]

      def new
        @promotion_action = @promotion.promotion_actions.build(
          type: @promotion_action_type,
          calculator_type: params[:promotion_action][:calculator_type]
        )
        render layout: false
      end

      def create
        @promotion_action = @promotion_action_type.new(permitted_resource_params)
        @promotion_action.promotion = @promotion
        if @promotion_action.save
          flash[:success] = t('spree.successfully_created', resource: t('spree.promotion_action'))
        end
        redirect_to location_after_save
      end

      def destroy
        @promotion_action = @promotion.promotion_actions.find(params[:id])
        if @promotion_action.discard
          flash[:success] = t('spree.successfully_removed', resource: t('spree.promotion_action'))
        end
        redirect_to location_after_save
      end

      private

      def location_after_save
        solidus_friendly_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_promotion
        @promotion = Spree::Promotion.find(params[:promotion_id])
      end

      def validate_promotion_action_type
        requested_type = params[:promotion_action].delete(:type)
        promotion_action_types = SolidusFriendlyPromotions.config.actions
        @promotion_action_type = promotion_action_types.detect do |klass|
          klass.name == requested_type
        end
        if !@promotion_action_type
          flash[:error] = t('spree.invalid_promotion_action')
          respond_to do |format|
            format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
            format.js   { render layout: false }
          end
        end
      end
    end
  end
end
