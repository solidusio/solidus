# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionActionsController < Spree::Admin::BaseController
      before_action :validate_level, only: :new
      before_action :load_promotion, only: [:create, :destroy, :new, :update]
      before_action :validate_promotion_action_type, only: :create

      def new
        if params.dig(:promotion_action, :type)
          validate_promotion_action_type
          @promotion_action = @promotion.actions.build(type: @promotion_action_type)

          if params.dig(:promotion_action, :calculator_type)
            @promotion_action.calculator_type = params[:promotion_action][:calculator_type]
          end
        end
        render layout: false
      end

      def create
        @promotion_action = @promotion_action_type.new(promotion_action_params)
        @promotion_action.promotion = @promotion
        if @promotion_action.save(validate: false)
          flash[:success] =
            t('spree.successfully_created', resource: SolidusFriendlyPromotions::PromotionAction.model_name.human)
          redirect_to location_after_save, format: :html
        else
          render :new, layout: false
        end
      end

      def update
        @promotion_action = @promotion.actions.find(params[:id])
        @promotion_action.assign_attributes(promotion_action_params)
        if @promotion_action.save
          flash[:success] =
            t('spree.successfully_updated', resource: SolidusFriendlyPromotions::PromotionAction.model_name.human)
          redirect_to location_after_save, format: :html
        else
          render :edit
        end
      end

      def destroy
        @promotion_action = @promotion.actions.find(params[:id])
        if @promotion_action.discard
          flash[:success] =
            t('spree.successfully_removed', resource: SolidusFriendlyPromotions::PromotionAction.model_name.human)
        end
        redirect_to location_after_save, format: :html
      end

      private

      def location_after_save
        solidus_friendly_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_promotion
        @promotion = SolidusFriendlyPromotions::Promotion.find(params[:promotion_id])
      end

      def validate_level
        requested_level = params[:level].to_s
        if requested_level.in?(["line_item", "shipment"])
          @level = requested_level
        else
          @level = "line_item"
          flash.now[:error] = t(:invalid_promotion_rule_level, scope: :solidus_friendly_promotions)
        end
      end

      def promotion_action_params
        params[:promotion_action].try(:permit!) || {}
      end

      def validate_promotion_action_type
        requested_type = params[:promotion_action].delete(:type)
        promotion_action_types = SolidusFriendlyPromotions.config.actions
        @promotion_action_type = promotion_action_types.detect do |klass|
          klass.name == requested_type
        end
        return if @promotion_action_type

        flash[:error] = t('solidus_friendly_promotions.invalid_promotion_action')
        respond_to do |format|
          format.html { redirect_to solidus_friendly_promotions.edit_admin_promotion_path(@promotion) }
          format.js   { render layout: false }
        end
      end
    end
  end
end
