# frozen_string_literal: true

class Spree::Admin::PromotionRulesController < Spree::Admin::BaseController
  helper "spree/promotion_rules"

  before_action :load_promotion, only: [:create, :destroy]
  before_action :validate_promotion_rule_type, only: :create

  def create
    @promotion_rule = @promotion_rule_type.new(promotion_rule_params)
    @promotion_rule.promotion = @promotion
    if @promotion_rule.save
      flash[:success] = t("spree.successfully_created", resource: t("spree.promotion_rule"))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
      format.js { render layout: false }
    end
  end

  def destroy
    @promotion_rule = @promotion.promotion_rules.find(params[:id])
    if @promotion_rule.destroy
      flash[:success] = t("spree.successfully_removed", resource: t("spree.promotion_rule"))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
      format.js { render layout: false }
    end
  end

  private

  def load_promotion
    @promotion = Spree::Promotion.find(params[:promotion_id])
  end

  def model_class
    Spree::PromotionRule
  end

  def validate_promotion_rule_type
    requested_type = params[:promotion_rule].delete(:type)
    promotion_rule_types = Spree::Config.promotions.rules
    @promotion_rule_type = promotion_rule_types.detect do |klass|
      klass.name == requested_type
    end
    if !@promotion_rule_type
      flash[:error] = t("spree.invalid_promotion_rule")
      respond_to do |format|
        format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
        format.js { render layout: false }
      end
    end
  end

  def promotion_rule_params
    params[:promotion_rule].permit!
  end
end
