module Spree
  module Admin
    class RefundsController < ResourceController
      belongs_to 'solidus/payment'
      before_action :load_order

      helper_method :refund_reasons

      rescue_from Solidus::Core::GatewayError, with: :solidus_core_gateway_error, only: :create

      private

      def location_after_save
        admin_order_payments_path(@payment.order)
      end

      def load_order
        # the solidus/admin/shared/order_tabs partial expects the @order instance variable to be set
        @order = @payment.order if @payment
      end

      def refund_reasons
        @refund_reasons ||= RefundReason.active.all
      end

      def build_resource
        super.tap do |refund|
          refund.amount = refund.payment.credit_allowed
        end
      end

      def solidus_core_gateway_error(error)
        flash[:error] = error.message
        render :new
      end
    end
  end
end
