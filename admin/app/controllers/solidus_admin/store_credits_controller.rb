# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditsController < SolidusAdmin::BaseController
    before_action :set_user

    def index
      @store_credits = Spree::StoreCredit.where(user_id: @user.id).order(id: :desc)

      respond_to do |format|
        format.html { render component("users/store_credits/index").new(user: @user, store_credits: @store_credits) }
      end
    end

    private

    def set_user
      @user = Spree.user_class.find(params[:id])
    end
  end
end
