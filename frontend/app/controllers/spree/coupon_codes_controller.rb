# frozen_string_literal: true

module Spree
  class CouponCodesController < Spree::StoreController
    include ActionView::Helpers::OutputSafetyHelper

    before_action :load_order, only: :create
    around_action :lock_order, only: :create

    def create
      authorize! :update, @order, cookies.signed[:guest_token]

      if params[:coupon_code].present?
        @order.coupon_code = params[:coupon_code]
        handler = PromotionHandler::Coupon.new(@order).apply

        respond_with(@order) do |format|
          format.html do
            if handler.successful?
              flash[:success] = handler.success
              redirect_to cart_path
            else
              flash.now[:error] = safe_join(handler.errors.full_messages, " <br /> ".html_safe)
              render 'spree/coupon_codes/new'
            end
          end
        end
      end
    end

    private

    def load_order
      @order = current_order
    end
  end
end
