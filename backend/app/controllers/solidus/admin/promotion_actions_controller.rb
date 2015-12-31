class Solidus::Admin::PromotionActionsController < Solidus::Admin::BaseController
  before_action :load_promotion, only: [:create, :destroy]
  before_action :validate_promotion_action_type, only: :create

  def create
    @calculators = Solidus::Promotion::Actions::CreateAdjustment.calculators
    @promotion_action = params[:action_type].constantize.new(params[:promotion_action])
    @promotion_action.promotion = @promotion
    if @promotion_action.save
      flash[:success] = Solidus.t(:successfully_created, :resource => Solidus.t(:promotion_action))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion)}
      format.js   { render :layout => false }
    end
  end

  def destroy
    @promotion_action = @promotion.promotion_actions.find(params[:id])
    if @promotion_action.destroy
      flash[:success] = Solidus.t(:successfully_removed, :resource => Solidus.t(:promotion_action))
    end
    respond_to do |format|
      format.html { redirect_to spree.edit_admin_promotion_path(@promotion)}
      format.js   { render :layout => false }
    end
  end

  private

  def load_promotion
    @promotion = Solidus::Promotion.find(params[:promotion_id])
  end

  def validate_promotion_action_type
    valid_promotion_action_types = Rails.application.config.spree.promotions.actions.map(&:to_s)
    if !valid_promotion_action_types.include?(params[:action_type])
      flash[:error] = Solidus.t(:invalid_promotion_action)
      respond_to do |format|
        format.html { redirect_to spree.edit_admin_promotion_path(@promotion)}
        format.js   { render :layout => false }
      end
    end
  end
end
