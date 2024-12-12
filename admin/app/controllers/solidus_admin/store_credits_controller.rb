# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditsController < SolidusAdmin::BaseController
    before_action :set_user
    before_action :set_store_credit, only: [:show, :edit_amount, :update_amount, :edit_memo, :update_memo]
    before_action :set_store_credit_reasons, only: [:edit_amount, :update_amount]

    def index
      @store_credits = Spree::StoreCredit.where(user_id: @user.id).order(id: :desc)

      respond_to do |format|
        format.html { render component("users/store_credits/index").new(user: @user, store_credits: @store_credits) }
      end
    end

    def show
      @store_credit_events = @store_credit.store_credit_events.chronological

      respond_to do |format|
        format.html { render component("users/store_credits/show").new(user: @user, store_credit: @store_credit, events: @store_credit_events) }
      end
    end

    def edit_amount
      @store_credit_events = @store_credit.store_credit_events.chronological

      respond_to do |format|
        format.html {
          render component("users/store_credits/edit_amount").new(
            user: @user,
            store_credit: @store_credit,
            events: @store_credit_events,
            reasons: @store_credit_reasons
        )
        }
      end
    end

    def update_amount
      return unless ensure_amount
      return unless ensure_store_credit_reason

      if @store_credit.update_amount(permitted_store_credit_params[:amount], @store_credit_reason, spree_current_user)
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.user_store_credit_path(@user, @store_credit), status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        render_edit_amount_with_errors and return
      end
    end

    def edit_memo
      @store_credit_events = @store_credit.store_credit_events.chronological

      respond_to do |format|
        format.html {
          render component("users/store_credits/edit_memo").new(
            user: @user,
            store_credit: @store_credit,
            events: @store_credit_events,
          )
        }
      end
    end

    def update_memo
      if @store_credit.update(memo: permitted_store_credit_params[:memo])
        flash[:notice] = t('.success')
      else
        # Memo update failures are nearly impossible to trigger due to lack of validation.
        flash[:error] = t('.failure')
      end

      respond_to do |format|
        format.html do
          redirect_to solidus_admin.user_store_credit_path(@user, @store_credit), status: :see_other
        end

        format.turbo_stream do
          render turbo_stream: '<turbo-stream action="refresh" />'
        end
      end
    end

    private

    def set_store_credit
      @store_credit = Spree::StoreCredit.find(params[:id])
    end

    def set_user
      @user = Spree.user_class.find(params[:user_id])
    end

    def set_store_credit_reasons
      @store_credit_reasons = Spree::StoreCreditReason.active.order(:name)
    end

    def permitted_store_credit_params
      permitted_params = [:amount, :currency, :category_id, :memo]
      permitted_params << :store_credit_reason_id if action_name.to_sym == :update_amount

      params.require(:store_credit).permit(permitted_params).merge(created_by: spree_current_user)
    end

    def render_edit_amount_with_errors
      @store_credit_events = @store_credit.store_credit_events.chronological

      respond_to do |format|
        format.html do
          render component("users/store_credits/edit_amount").new(
            user: @user,
            store_credit: @store_credit,
            events: @store_credit_events,
            reasons: @store_credit_reasons
          ),
            status: :unprocessable_entity
        end
      end
    end

    def ensure_amount
      if permitted_store_credit_params[:amount].blank?
        @store_credit.errors.add(:amount, :greater_than, count: 0, value: permitted_store_credit_params[:amount])
        render_edit_amount_with_errors
        return false
      end
      true
    end

    def ensure_store_credit_reason
      @store_credit_reason = Spree::StoreCreditReason.find_by(id: permitted_store_credit_params[:store_credit_reason_id])

      if @store_credit_reason.blank?
        @store_credit.errors.add(:store_credit_reason_id, "Store Credit reason must be provided")
        render_edit_amount_with_errors
        return false
      end
      true
    end
  end
end
