# frozen_string_literal: true

module Spree
  module Admin
    class LogEntriesController < Spree::Admin::BaseController
      before_action :find_order_and_payment
      before_action :set_breadcrumbs

      def index
        Spree::Deprecation.warn 'Using a dedicated route for payment log entries ' \
          'has been deprecated in favor of displaying the log entries on ' \
          'the payment screen itself.', caller_locations(0)
        @log_entries = @payment.log_entries
      end

      private

      def find_order_and_payment
        @order = Spree::Order.where(number: params[:order_id]).first!
        @payment = @order.payments.find(params[:payment_id])
      end

      def set_breadcrumbs
        set_order_breadcrumbs
        add_breadcrumb Spree::Payment.model_name.human
        add_breadcrumb plural_resource_name(Spree::LogEntry)
      end
    end
  end
end
