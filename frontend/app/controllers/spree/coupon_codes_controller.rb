# frozen_string_literal: true

module Spree
  class CouponCodesController < Spree::StoreController
    before_action :load_order, only: :create
    around_action :lock_order, only: :create

    def create
      if params[:coupon_code].present?
        @order.coupon_code = params[:coupon_code]
        handler = PromotionHandler::Coupon.new(@order).apply

        if handler.successful?
          flash[:success] = handler.success
          respond_with(@order) { |format| format.html { redirect_to cart_path } }
        else
          flash.now[:error] = handler.error
          respond_with(@order) { |format| format.html { render 'spree/coupon_codes/new' } }
        end
      end
    end

    private

    def load_order
      @order = current_order
    end
  end
end
