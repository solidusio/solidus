# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class ConditionsController < Spree::Admin::BaseController
      helper "solidus_friendly_promotions/admin/conditions"

      before_action :load_promotion_action, only: [:create, :destroy, :update, :new]
      rescue_from ActiveRecord::SubclassNotFound, with: :invalid_rule_error

      def new
        if params.dig(:promotion_rule, :type)
          promotion_rule_type = params[:promotion_rule][:type]
          @promotion_rule = @promotion_action.conditions.build(type: promotion_rule_type)
        end
        render layout: false
      end

      def create
        @promotion_rule = @promotion_action.conditions.build(promotion_rule_params)
        if @promotion_rule.save
          flash[:success] =
            t("spree.successfully_created", resource: SolidusFriendlyPromotions::PromotionRule.model_name.human)
        end
        redirect_to location_after_save
      end

      def update
        @promotion_rule = @promotion_action.conditions.find(params[:id])
        @promotion_rule.assign_attributes(promotion_rule_params)
        if @promotion_rule.save
          flash[:success] =
            t("spree.successfully_updated", resource: SolidusFriendlyPromotions::PromotionRule.model_name.human)
        end
        redirect_to location_after_save
      end

      def destroy
        @promotion_rule = @promotion_action.conditions.find(params[:id])
        if @promotion_rule.destroy
          flash[:success] =
            t("spree.successfully_removed", resource: SolidusFriendlyPromotions::PromotionRule.model_name.human)
        end
        redirect_to location_after_save
      end

      private

      def invalid_rule_error
        flash[:error] = t("solidus_friendly_promotions.invalid_rule")
        redirect_to location_after_save
      end

      def location_after_save
        solidus_friendly_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_promotion_action
        @promotion = SolidusFriendlyPromotions::Promotion.find(params[:promotion_id])
        @promotion_action = @promotion.actions.find(params[:promotion_action_id])
      end

      def model_class
        SolidusFriendlyPromotions::PromotionRule
      end

      def promotion_rule_params
        params[:promotion_rule].try(:permit!) || {}
      end
    end
  end
end
