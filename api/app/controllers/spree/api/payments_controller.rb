# frozen_string_literal: true

module Spree
  module Api
    class PaymentsController < Spree::Api::BaseController
      before_action :find_order
      around_action :lock_order, only: [:create, :update, :destroy, :authorize, :capture, :purchase, :void, :credit]
      before_action :find_payment, only: [:update, :show, :authorize, :purchase, :capture, :void, :credit]

      def index
        @payments = paginate(@order.payments.ransack(params[:q]).result)
        respond_with(@payments)
      end

      def new
        @payment_methods = Spree::PaymentMethod.available_to_users.available_to_admin
        respond_with(@payment_method)
      end

      def create
        @order.validate_payments_attributes(payment_params)
        @payment = PaymentCreate.new(@order, payment_params).build
        if @payment.save
          respond_with(@payment, status: 201, default_template: :show)
        else
          invalid_resource!(@payment)
        end
      end

      def update
        authorize! params[:action], @payment
        if !@payment.pending?
          render 'update_forbidden', status: 403
        elsif @payment.update(payment_params)
          respond_with(@payment, default_template: :show)
        else
          invalid_resource!(@payment)
        end
      end

      def show
        respond_with(@payment)
      end

      def authorize
        perform_payment_action(:authorize)
      end

      def capture
        perform_payment_action(:capture)
      end

      def purchase
        perform_payment_action(:purchase)
      end

      def void
        perform_payment_action(:void_transaction)
      end

      private

      def find_order
        @order = Spree::Order.find_by(number: order_id)
        authorize! :read, @order, order_token
      end

      def find_payment
        @payment = @order.payments.find(params[:id])
      end

      def perform_payment_action(action, *args)
        authorize! action, Payment
        @payment.send("#{action}!", *args)
        respond_with(@payment, default_template: :show)
      end

      def payment_params
        params.require(:payment).permit(permitted_payment_attributes)
      end
    end
  end
end
