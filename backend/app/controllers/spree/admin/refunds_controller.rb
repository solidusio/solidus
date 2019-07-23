# frozen_string_literal: true

module Spree
  module Admin
    class RefundsController < ResourceController
      belongs_to 'spree/payment'
      before_action :load_order
      before_action :set_breadcrumbs

      helper_method :refund_reasons

      rescue_from Spree::Core::GatewayError, with: :spree_core_gateway_error

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

      def build_resource
        super.tap do |refund|
          refund.amount = refund.payment.credit_allowed
        end
      end

      def spree_core_gateway_error(error)
        flash[:error] = error.message
        render :new
      end

      def set_breadcrumbs
        set_order_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Payment), spree.admin_order_payments_path(@order)
        add_breadcrumb "#{Spree::Payment.model_name.human} #{@refund.payment.id}", admin_order_payment_path(@refund.payment.order, @refund.payment)
        add_breadcrumb "#{t('spree.editing_refund')} #{@refund.id}" if action_name == 'edit'
        add_breadcrumb t('spree.new_refund') if action_name == 'new'
      end
    end
  end
end
