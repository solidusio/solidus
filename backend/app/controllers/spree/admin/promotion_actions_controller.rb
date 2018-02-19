# frozen_string_literal: true

class Spree::Admin::PromotionActionsController < Spree::Admin::BaseController
  before_action :load_promotion, only: [:create, :destroy]
  before_action :validate_promotion_action_type, only: :create

  def create
    @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
    @promotion_action = @promotion_action_type.new(params[:promotion_action])
    @promotion_action.promotion = @promotion
    if @promotion_action.save
      flash[:success] = t('spree.successfully_created', resource: t('spree.promotion_action'))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
      format.js   { render layout: false }
    end
  end

  def destroy
    @promotion_action = @promotion.promotion_actions.find(params[:id])
    if @promotion_action.discard
      flash[:success] = t('spree.successfully_removed', resource: t('spree.promotion_action'))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion) }
      format.js   { render layout: false }
    end
  end

  private

  def load_promotion
    @promotion = Spree::Promotion.find(params[:promotion_id])
  end

  def validate_promotion_action_type
    requested_type = params[:action_type]
    promotion_action_types = Rails.application.config.spree.promotions.actions
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
