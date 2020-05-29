# frozen_string_literal: true

module Spree
  module Admin
    class RefundsController < ResourceController
      belongs_to 'spree/payment'
      before_action :load_order

      helper_method :refund_reasons

      rescue_from Spree::Core::GatewayError, with: :spree_core_gateway_error

      def create
        @refund.attributes = refund_params.merge(perform_after_create: false)
        if @refund.save && @refund.perform!
          flash[:success] = flash_message_for(@refund, :successfully_created)
          respond_with(@refund) do |format|
            format.html { redirect_to location_after_save }
          end
        else
          flash.now[:error] = @refund.errors.full_messages.join(", ")
          respond_with(@refund) do |format|
            format.html { render action: 'new' }
          end
        end
      end

      private

      def location_after_save
        admin_order_payments_path(@payment.order)
      end

      def load_order
        # the spree/admin/shared/order_tabs partial expects the @order instance variable to be set
        @order = @payment.order if @payment
      end

      def refund_reasons
        @refund_reasons ||= Spree::RefundReason.active.all
      end

      def refund_params
        params.require(:refund).permit!
      end

      def build_resource
        super.tap do |refund|
          refund.amount = refund.payment.credit_allowed
        end
      end

      def spree_core_gateway_error(error)
        flash[:error] = error.message
        render :new
      end
    end
  end
end
