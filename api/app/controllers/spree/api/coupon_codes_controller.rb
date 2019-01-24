# frozen_string_literal: true

module Spree
  module Api
    class CouponCodesController < Spree::Api::BaseController
      before_action :load_order
      around_action :lock_order

      def create
        authorize! :update, @order, order_token

        @order.coupon_code = params[:coupon_code]
        @handler = PromotionHandler::Coupon.new(@order).apply

        if @handler.successful?
          render 'spree/api/promotions/handler', status: 200
        else
          logger.error("apply_coupon_code_error=#{@handler.error.inspect}")
          render 'spree/api/promotions/handler', status: 422
        end
      end

      def destroy
        authorize! :update, @order, order_token

        @order.coupon_code = params[:id]
        @handler = PromotionHandler::Coupon.new(@order).remove

        if @handler.successful?
          render 'spree/api/promotions/handler', status: 200
        else
          logger.error("remove_coupon_code_error=#{@handler.error.inspect}")
          render 'spree/api/promotions/handler', status: 422
        end
      end

      private

      def load_order
        @order = Spree::Order.find_by!(number: params[:order_id])
      end
    end
  end
end
