# frozen_string_literal: true

module Spree
  module Admin
    class CouponCodesController < Spree::Admin::BaseController
      before_action :load_order
      around_action :lock_order

      def create
        authorize! :update, @order, order_token

        @order.coupon_code = params[:coupon_code]
        @handler = PromotionHandler::Coupon.new(@order).apply

        if @handler.successful?
          return render json: handler_response, status: 200
        end

        logger.error("apply_coupon_code_error=#{@handler.error.inspect}")
        render json: handler_response, status: 422
      end

      def destroy
        authorize! :update, @order, order_token

        @order.coupon_code = params[:id]
        @handler = PromotionHandler::Coupon.new(@order).remove

        if @handler.successful?
          return render json: handler_response, status: 200
        end

        logger.error("remove_coupon_code_error=#{@handler.error.inspect}")
        render json: handler_response, status: 422
      end

      private

      def handler_response
        { success: @handler.success, error: @handler.error, successful: @handler.successful?, status_code: @handler.status_code }
      end

      def load_order
        @order = Spree::Order.find_by!(number: params[:order_id])
      end
    end
  end
end
