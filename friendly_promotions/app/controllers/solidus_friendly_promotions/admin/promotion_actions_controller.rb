# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionActionsController < Spree::Admin::ResourceController
      before_action :load_promotion
      before_action :validate_promotion_action_type, only: [:create]

      helper 'solidus_friendly_promotions/admin/promotion_actions'

      def new
        if params.dig(:promotion_action, :type)
          validate_promotion_action_type
        end
        @promotion_action = @promotion.promotion_actions.build(
          type: @promotion_action_type,
        )
        if @promotion_action.respond_to?(:calculator_type) && params.dig(:promotion_action, :calculator_type)
          @promotion_action.calculator_type = params.dig(:promotion_action, :calculator_type)
        end
        render layout: false
      end

      def edit
        if @promotion_action.calculator.class.name != params.dig(:promotion_action, :calculator_type)
          @promotion_action.calculator = permitted_resource_params[:calculator_type].constantize.new
        end
        render layout: false
      end

      def create
        @promotion_action = @promotion_action_type.new(permitted_resource_params)
        @promotion_action.promotion = @promotion
        if @promotion_action.save
          flash[:success] = t('spree.successfully_created', resource: t('spree.promotion_action'))
          redirect_to location_after_save, format: :html
        else
          render :new, layout: false
        end
      end

      def update
        @promotion_action = @promotion.promotion_actions.find(params[:id])
        @promotion_action.assign_attributes(permitted_resource_params)
        if @promotion_action.save
          flash[:success] = t('spree.successfully_updated', resource: t('spree.promotion_action'))
          redirect_to location_after_save, format: :html
        else
          render :edit
        end
      end

      def destroy
        @promotion_action = @promotion.promotion_actions.find(params[:id])
        if @promotion_action.discard
          flash[:success] = t('spree.successfully_removed', resource: t('spree.promotion_action'))
        end
        redirect_to location_after_save, format: :html
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
