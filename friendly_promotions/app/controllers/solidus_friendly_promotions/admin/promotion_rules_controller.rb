# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionRulesController < Spree::Admin::BaseController
      helper 'spree/promotion_rules'

      before_action :validate_level, only: [:new, :edit, :create]
      before_action :load_promotion, only: [:create, :destroy, :update, :new]
      before_action :validate_promotion_rule_type, only: [:create]

      def new
        if params.dig(:promotion_rule, :type)
          validate_promotion_rule_type
          @promotion_rule = @promotion.rules.build(type: @promotion_rule_type)
        end
        render layout: false
      end

      def create
        @promotion_rule = @promotion_rule_type.new(promotion_rule_params)
        @promotion_rule.promotion = @promotion
        if @promotion_rule.save
          flash[:success] = t('spree.successfully_created', resource: t('spree.promotion_rule'))
        end
        redirect_to location_after_save
      end

      def update
        @promotion_rule = @promotion.rules.find(params[:id])
        @promotion_rule.assign_attributes(promotion_rule_params)
        if @promotion_rule.save
          flash[:success] = t('spree.successfully_updated', resource: t('spree.promotion_rule'))
        end
        redirect_to location_after_save
      end

      def destroy
        @promotion_rule = @promotion.rules.find(params[:id])
        if @promotion_rule.destroy
          flash[:success] = t('spree.successfully_removed', resource: t('spree.promotion_rule'))
        end
        redirect_to location_after_save
      end

      private

      def location_after_save
        solidus_friendly_promotions.edit_admin_promotion_path(@promotion)
      end

      def load_promotion
        @promotion = SolidusFriendlyPromotions::Promotion.find(params[:promotion_id])
      end

      def model_class
        SolidusFriendlyPromotions::PromotionRule
      end

      def validate_promotion_rule_type
        requested_type = params[:promotion_rule].delete(:type)
        promotion_rule_types = SolidusFriendlyPromotions.config.send("#{@level}_rules")
        @promotion_rule_type = promotion_rule_types.detect do |klass|
          klass.name == requested_type
        end
        if !@promotion_rule_type
          flash[:error] = t('spree.invalid_promotion_rule')
          respond_to do |format|
            format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
            format.js   { render layout: false }
          end
        end
      end

      def validate_level
        requested_level = params[:level].to_s
        if requested_level.in?(["order", "line_item", "shipment"])
          @level = requested_level
        else
          @level = "order"
          flash.now[:error] = t(:invalid_promotion_rule_level, scope: :solidus_friendly_promotions)
        end
      end

      def promotion_rule_params
        params[:promotion_rule].permit!
      end

      def promotion_rule_types
        case params.dig(:level)
        when "order"
          SolidusFriendlyPromotions.config.order_rules
        when "line_item"
          SolidusFriendlyPromotions.config.line_item_rules
        when "shipment"
          SolidusFriendlyPromotions.config.shipment_rules
        end
      end
    end
  end
end
