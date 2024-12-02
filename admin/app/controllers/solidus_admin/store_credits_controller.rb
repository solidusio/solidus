# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditsController < SolidusAdmin::BaseController
    before_action :set_user
    before_action :set_store_credit, only: [:show]

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

    private

    def set_store_credit
      @store_credit = Spree::StoreCredit.find(params[:id])
    end

    def set_user
      @user = Spree.user_class.find(params[:user_id])
    end
  end
end
