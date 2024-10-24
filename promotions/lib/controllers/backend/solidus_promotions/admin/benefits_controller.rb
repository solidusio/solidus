# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class BenefitsController < Spree::Admin::BaseController
      before_action :load_promotion, only: [:create, :destroy, :new, :update, :edit]
      before_action :validate_benefit_type, only: [:create, :edit]

      def new
        @benefit = @promotion.benefits.build(benefit_params)
        render layout: false
      end

      def create
        @benefit = @benefit_type.new(benefit_params)
        @benefit.promotion = @promotion
        if @benefit.save(validate: false)
          flash[:success] =
            t("spree.successfully_created", resource: SolidusPromotions::Benefit.model_name.human)
          redirect_to location_after_save, format: :html
        else
          render :new, layout: false
        end
      end

      def edit
        @benefit = @promotion.benefits.find(params[:id])
        if params.dig(:benefit, :calculator_type)
          @benefit.calculator_type = params[:benefit][:calculator_type]
        end
        render layout: false
      end

      def update
        @benefit = @promotion.benefits.find(params[:id])
        @benefit.assign_attributes(benefit_params)
        if @benefit.save
          flash[:success] =
            t("spree.successfully_updated", resource: SolidusPromotions::Benefit.model_name.human)
          redirect_to location_after_save, format: :html
        else
          render :edit
        end
      end

      def destroy
        @benefit = @promotion.benefits.find(params[:id])
        if @benefit.destroy
          flash[:success] =
            t("spree.successfully_removed", resource: SolidusPromotions::Benefit.model_name.human)
        end
        redirect_to location_after_save, format: :html
      end

      private

      def location_after_save
        solidus_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_promotion
        @promotion = SolidusPromotions::Promotion.find(params[:promotion_id])
      end

      def benefit_params
        params[:benefit].try(:permit!) || {}
      end

      def validate_benefit_type
        requested_type = params[:benefit].delete(:type)
        benefit_types = SolidusPromotions.config.benefits
        @benefit_type = benefit_types.detect do |klass|
          klass.name == requested_type
        end
        return if @benefit_type

        flash[:error] = t("solidus_promotions.invalid_benefit")
        respond_to do |format|
          format.html { redirect_to solidus_promotions.edit_admin_promotion_path(@promotion) }
          format.js { render layout: false }
        end
      end
    end
  end
end
