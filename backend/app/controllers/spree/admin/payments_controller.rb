# frozen_string_literal: true

module Spree
  module Admin
    class PaymentsController < Spree::Admin::BaseController
      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      before_action :load_order, only: [:create, :new, :index, :fire]
      before_action :load_payment, except: [:create, :new, :index, :fire]
      before_action :load_payment_for_fire, only: :fire
      before_action :load_data
      before_action :require_bill_address, only: [:index]

      respond_to :html

      def index
        @payments = @order.payments.includes(refunds: :reason)
        @refunds = @payments.flat_map(&:refunds)
        redirect_to new_admin_order_payment_url(@order) if @payments.empty?
      end

      def new
        @payment = @order.payments.build(amount: @order.outstanding_balance)
      end

      def create
        @payment = PaymentCreate.new(@order, object_params).build
        if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
          @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
        end

        begin
          if @payment.save
            if @order.completed?
              # If the order was already complete then go ahead and process the payment
              # (auth and/or capture depending on payment method configuration)
              @payment.process! if @payment.checkout?
            else
              # Transition order as far as it will go.
              while @order.next; end
            end

            flash[:success] = flash_message_for(@payment, :successfully_created)
            redirect_to admin_order_payments_path(@order)
          else
            flash[:error] = t('spree.payment_could_not_be_created')
            render :new
          end
        rescue Spree::Core::GatewayError => error
          flash[:error] = error.message.to_s
          redirect_to new_admin_order_payment_path(@order)
        end
      end

      def fire
        return unless (event = params[:e]) && @payment.payment_source

        # Because we have a transition method also called void, we do this to avoid conflicts.
        event = "void_transaction" if event == "void"
        if @payment.send("#{event}!")
          flash[:success] = t('spree.payment_updated')
        else
          flash[:error] = t('spree.cannot_perform_operation')
        end
      rescue Spree::Core::GatewayError => ge
        flash[:error] = ge.message.to_s
      ensure
        redirect_to admin_order_payments_path(@order)
      end

      private

      def object_params
        if params[:payment] && params[:payment_source] && (source_params = params.delete(:payment_source)[params[:payment][:payment_method_id]])
          params[:payment][:source_attributes] = source_params
        end

        params.require(:payment).permit(permitted_payment_attributes)
      end

      def load_data
        @amount = params[:amount] || load_order.total
        @payment_methods = Spree::PaymentMethod.active.available_to_admin
        if @payment && @payment.payment_method
          @payment_method = @payment.payment_method
        else
          @payment_method = @payment_methods.first
        end
      end

      def load_order
        @order = Spree::Order.find_by!(number: params[:order_id])
        authorize! action, @order
        @order
      end

      def load_payment
        @payment = Spree::Payment.find(params[:id])
      end

      def load_payment_for_fire
        load_payment
        authorize! params[:e].to_sym, @payment
      end

      def model_class
        Spree::Payment
      end

      def require_bill_address
        if Spree::Config[:order_bill_address_used] && @order.bill_address.nil?
          flash[:notice] = t('spree.fill_in_customer_info')
          redirect_to edit_admin_order_customer_url(@order)
        end
      end

      def insufficient_stock_error
        flash[:error] = t('spree.insufficient_stock_for_order')
        redirect_to new_admin_order_payment_url(@order)
      end
    end
  end
end
