# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class ConditionsController < Spree::Admin::BaseController
      helper "solidus_promotions/admin/conditions"

      before_action :load_benefit, only: [:create, :destroy, :update, :new]
      rescue_from ActiveRecord::SubclassNotFound, with: :invalid_condition_error

      def new
        @condition = @benefit.conditions.build(condition_params)
        render layout: false
      end

      def create
        @condition = @benefit.conditions.build(condition_params)
        if @condition.save
          flash[:success] =
            t("spree.successfully_created", resource: model_class.model_name.human)
        end
        redirect_to location_after_save
      end

      def update
        @condition = @benefit.conditions.find(params[:id])
        @condition.assign_attributes(condition_params)
        if @condition.save
          flash[:success] =
            t("spree.successfully_updated", resource: model_class.model_name.human)
        end
        redirect_to location_after_save
      end

      def destroy
        @condition = @benefit.conditions.find(params[:id])
        if @condition.destroy
          flash[:success] =
            t("spree.successfully_removed", resource: model_class.model_name.human)
        end
        redirect_to location_after_save
      end

      private

      def invalid_condition_error
        flash[:error] = t("solidus_promotions.invalid_condition")
        redirect_to location_after_save
      end

      def location_after_save
        solidus_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_benefit
        @promotion = SolidusPromotions::Promotion.find(params[:promotion_id])
        @benefit = @promotion.benefits.find(params[:benefit_id])
      end

      def model_class
        SolidusPromotions::Condition
      end

      def condition_params
        params[:condition].try(:permit!) || {}
      end
    end
  end
end
