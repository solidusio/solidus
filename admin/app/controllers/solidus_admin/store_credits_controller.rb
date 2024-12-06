# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditsController < SolidusAdmin::BaseController
    before_action :set_user
    before_action :set_store_credit, only: [:show, :edit_amount, :update_amount]
    before_action :set_store_credit_reasons, only: [:edit_amount, :update_amount]

    SolidusAdmin::StoreCreditsController
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

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "store_credit_details", # Target a container ID in your HTML
            partial: "users/store_credits/show", # Use the appropriate partial
            locals: { user: @user, store_credit: @store_credit, events: @store_credit_events }
          )
        end
      end
    end

    def edit_amount
      @store_credit_events = @store_credit.store_credit_events.chronological

      respond_to do |format|
        format.html { render component("users/store_credits/edit_amount").new(
          user: @user,
          store_credit: @store_credit,
          events: @store_credit_events,
          reasons: @store_credit_reasons
        )}
      end
    end

    # def update_amount
    #   binding.pry
    #
    #   @store_credit_reason = Spree::StoreCreditReason.find_by(id: params[:store_credit_reason_id])
    #   unless @store_credit_reason
    #     @store_credit.errors.add(:base, t('spree.admin.store_credits.errors.store_credit_reason_required'))
    #     render_edit_page
    #   end
    #
    #   amount = params.require(:store_credit).require(:amount)
    #   if @store_credit.update_amount(amount, @store_credit_reason, spree_current_user)
    #     flash[:success] = flash_message_for(@store_credit, :successfully_updated)
    #     redirect_to admin_user_store_credit_path(@user, @store_credit)
    #   else
    #     flash[:error] = "#{t("spree.admin.store_credits.unable_to_update")}: #{@store_credit.errors.full_messages.join(', ')}"
    #     render(:edit_amount) && return
    #   end
    # end

    def wip_old_update_amount
      if @store_credit.update(permitted_store_credit_params)
        flash[:notice] = t('.success')
        redirect_to solidus_admin.user_store_credit_path(@user, @store_credit), status: :see_other
      else
        respond_to do |format|
          format.html { render component("users/store_credits/edit_amount").new(
            user: @user,
            store_credit: @store_credit,
            events: @store_credit_events,
            reasons: @store_credit_reasons
          ),
            status: :unprocessable_entity
          }
        end
      end
    end

    def update_amount
      @store_credit_reason = Spree::StoreCreditReason.find_by(id: params[:store_credit_reason_id])
      amount = params.require(:store_credit).require(:amount)

      if amount_changed?
        if @store_credit_reason.blank?
          @store_credit.errors.add(:base, "Store Credit reason must be provided")
          render_edit_page_with_errors and return
        end

        unless @store_credit.update_amount(amount, @store_credit_reason, spree_current_user)
          render_edit_page_with_errors and return
        end
      end

      @store_credit.update(memo: permitted_store_credit_params[:memo])

      flash[:notice] = t('.success')
      redirect_to solidus_admin.user_store_credit_path(@user, @store_credit), status: :see_other
    end

    private

    def render_edit_page_with_errors
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

    def permitted_store_credit_params
      params.require(:store_credit).permit([:amount, :currency, :category_id, :memo]).
        merge(created_by: spree_current_user)
    end

    def set_store_credit
      @store_credit = Spree::StoreCredit.find(params[:id])
    end

    def set_user
      @user = Spree.user_class.find(params[:user_id])
    end

    def set_store_credit_reasons
      @store_credit_reasons = Spree::StoreCreditReason.active.order(:name)
    end

    def amount_changed?
      # Add error if the amount is blank or nil. Let the model validation handle all other cases.
      if permitted_store_credit_params[:amount].blank?
        @store_credit.errors.add(:amount, :greater_than, count: 0, value: permitted_store_credit_params[:amount])
        return false
      end

      old_amount = @store_credit.amount
      new_amount = BigDecimal(permitted_store_credit_params[:amount])
      old_amount != new_amount
    end
  end
end
