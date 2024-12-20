# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditsController < SolidusAdmin::ResourcesController
    before_action :set_user
    before_action :set_store_credit, only: [:show, :edit_amount, :update_amount, :edit_memo, :update_memo, :edit_validity, :invalidate]
    before_action :set_store_credit_reasons, only: [:edit_amount, :update_amount, :edit_validity, :invalidate]
    before_action :set_store_credit_events, only: [:show]
    before_action :set_store_credit_categories, only: [:new]

    def index
      @store_credits = Spree::StoreCredit.where(user_id: @user.id).order(id: :desc)

      respond_to do |format|
        format.html { render component("users/store_credits/index").new(user: @user, store_credits: @store_credits) }
      end
    end

    def show
      respond_to do |format|
        format.html { render component("users/store_credits/show").new(user: @user, store_credit: @store_credit, events: @store_credit_events) }
      end
    end

    def new
      @store_credit ||= Spree::StoreCredit.new

      respond_to do |format|
        format.html {
          render component("users/store_credits/new").new(
            user: @user,
            store_credit: @store_credit,
            categories: @store_credit_categories
          )
        }
      end
    end

    def create
      @store_credit = @user.store_credits.build(
        permitted_resource_params.merge({
          created_by: spree_current_user,
          action_originator: spree_current_user
        })
      )

      return unless ensure_amount { render_new_with_errors }
      return unless ensure_store_credit_category { render_new_with_errors }

      if @store_credit.save
        flash[:notice] = t('.success')
        redirect_to after_create_path, status: :see_other
      else
        render_new_with_errors
      end
    end

    def edit_amount
      respond_to do |format|
        format.html {
          render component("users/store_credits/edit_amount").new(
            user: @user,
            store_credit: @store_credit,
            reasons: @store_credit_reasons
          )
        }
      end
    end

    def update_amount
      return unless ensure_amount { render_edit_with_errors }
      return unless ensure_store_credit_reason { render_edit_with_errors }

      if @store_credit.update_amount(permitted_resource_params[:amount], @store_credit_reason, spree_current_user)
        flash[:notice] = t('.success')
        redirect_to after_update_path, status: :see_other
      else
        render_edit_with_errors
      end
    end

    def edit_memo
      respond_to do |format|
        format.html {
          render component("users/store_credits/edit_memo").new(
            user: @user,
            store_credit: @store_credit,
          )
        }
      end
    end

    def update_memo
      if @store_credit.update(memo: permitted_resource_params[:memo])
        flash[:notice] = t('.success')
      else
        # Memo update failures are nearly impossible to trigger due to lack of validation.
        flash[:error] = t('.failure')
      end

      redirect_to after_update_path, status: :see_other
    end

    def edit_validity
      respond_to do |format|
        format.html {
          render component("users/store_credits/edit_validity").new(
            user: @user,
            store_credit: @store_credit,
            reasons: @store_credit_reasons
          )
        }
      end
    end

    def invalidate
      return unless ensure_store_credit_reason { render_edit_with_errors }

      if @store_credit.invalidate(@store_credit_reason, spree_current_user)
        flash[:notice] = t('.success')
      else
        # Ensure store_credit_reason handles invalid param/form submissions and modal re-rendering.
        # This is just a fallback error state in case anything goes wrong with StoreCredit#invalidate.
        flash[:error] = t('.failure')
      end

      redirect_to after_update_path, status: :see_other
    end

    private

    def resource_class = Spree::StoreCredit

    def set_store_credit
      @store_credit ||= Spree::StoreCredit.find(params[:id])
    end

    def set_user
      @user = Spree.user_class.find(params[:user_id])
    end

    def set_store_credit_reasons
      @store_credit_reasons = Spree::StoreCreditReason.active.order(:name)
    end

    def set_store_credit_categories
      @store_credit_categories = Spree::StoreCreditCategory.all.order(:name)
    end

    def set_store_credit_events
      @store_credit_events = @store_credit.store_credit_events.chronological
    end

    def permitted_resource_params
      permitted_params = [:amount, :currency, :category_id, :memo]
      permitted_params << :category_id if action_name.to_sym == :create
      permitted_params << :store_credit_reason_id if [:update_amount, :invalidate].include?(action_name.to_sym)

      params.require(:store_credit).permit(permitted_params).merge(created_by: spree_current_user)
    end

    def render_new_with_errors
      set_store_credit_categories

      page_component = component("users/store_credits/new").new(
        user: @user,
        store_credit: @store_credit,
        categories: @store_credit_categories
      )

      render_resource_form_with_errors(page_component)
    end

    def render_edit_with_errors
      set_store_credit_events

      template = if action_name.to_sym == :invalidate
        "edit_validity"
      else
        "edit_amount"
      end

      page_component = component("users/store_credits/#{template}").new(
        user: @user,
        store_credit: @store_credit,
        reasons: @store_credit_reasons
      )

      render_resource_form_with_errors(page_component)
    end

    def ensure_amount
      if permitted_resource_params[:amount].blank?
        @store_credit.errors.add(:amount, :greater_than, count: 0, value: permitted_resource_params[:amount])
        yield if block_given? # Block is for error template rendering on a per-action basis so this can be re-used.
        return false
      end
      true
    end

    def ensure_store_credit_reason
      @store_credit_reason = Spree::StoreCreditReason.find_by(id: permitted_resource_params[:store_credit_reason_id])

      if @store_credit_reason.blank?
        @store_credit.errors.add(:store_credit_reason_id, "Store Credit reason must be provided")
        yield if block_given? # Block is for error template rendering on a per-action basis so this can be re-used.
        return false
      end
      true
    end

    def ensure_store_credit_category
      @store_credit_category = Spree::StoreCreditCategory.find_by(id: permitted_resource_params[:category_id])

      if @store_credit_category.blank?
        @store_credit.errors.add(:category_id, "Store Credit category must be provided")
        yield if block_given? # Block is for error template rendering on a per-action basis so this can be re-used.
        return false
      end
      true
    end

    def after_create_path
      solidus_admin.user_store_credits_path(@user)
    end

    def after_update_path
      solidus_admin.user_store_credit_path(@user, @store_credit)
    end
  end
end
