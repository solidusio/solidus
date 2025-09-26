# frozen_string_literal: true

module Spree
  module Api
    class CheckoutsController < Spree::Api::BaseController
      before_action :load_order, only: [:next, :advance, :update, :complete]
      around_action :lock_order, only: [:next, :advance, :update, :complete]
      before_action :update_order_state, only: [:next, :advance, :update, :complete]

      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      include Spree::Core::ControllerHelpers::PaymentParameters

      include Spree::Core::ControllerHelpers::Order

      def next
        authorize! :update, @order, order_token
        if !expected_total_ok?(params[:expected_total])
          respond_with(@order, default_template: "spree/api/orders/expected_total_mismatch", status: 400)
          return
        end
        @order.next!
        respond_with(@order, default_template: "spree/api/orders/show", status: 200)
      end

      def advance
        authorize! :update, @order, order_token
        @order.contents.advance
        respond_with(@order, default_template: "spree/api/orders/show", status: 200)
      end

      def complete
        authorize! :update, @order, order_token
        if !expected_total_ok?(params[:expected_total])
          respond_with(@order, default_template: "spree/api/orders/expected_total_mismatch", status: 400)
        else
          @order.complete!
          respond_with(@order, default_template: "spree/api/orders/show", status: 200)
        end
      end

      def update
        authorize! :update, @order, order_token

        if Spree::Config.order_update_attributes_class.new(@order, update_params, request_env: request.headers.env).call
          if can?(:admin, @order) && user_id.present?
            @order.associate_user!(Spree.user_class.find(user_id))
          end

          return if after_update_attributes

          if @order.completed? || @order.next!
            state_callback(:after)
            respond_with(@order, default_template: "spree/api/orders/show")
          end
        else
          invalid_resource!(@order)
        end
      end

      private

      def user_id
        params[:order][:user_id] if params[:order]
      end

      def update_params
        state = @order.state
        case state.to_sym
        when :cart, :address
          massaged_params.fetch(:order, {}).permit(
            permitted_checkout_address_attributes
          )
        when :delivery
          massaged_params.require(:order).permit(
            permitted_checkout_delivery_attributes
          )
        when :payment
          massaged_params.require(:order).permit(
            permitted_checkout_payment_attributes
          )
        else
          massaged_params.fetch(:order, {}).permit(
            permitted_checkout_confirm_attributes
          )
        end
      end

      def massaged_params
        massaged_params = params.deep_dup

        set_payment_parameters_amount(massaged_params, @order)

        massaged_params
      end

      # Should be overridden if you have areas of your checkout that don't match
      # up to a step within checkout_steps, such as a registration step
      def skip_state_validation?
        false
      end

      def load_order
        @order = Spree::Order.find_by!(number: params[:id])
      end

      def update_order_state
        @order.state = params[:state] if params[:state]
        state_callback(:before)
      end

      def state_callback(before_or_after = :before)
        method_name = :"#{before_or_after}_#{@order.state}"
        send(method_name) if respond_to?(method_name, true)
      end

      def after_update_attributes
        false
      end

      def order_id
        super || params[:id]
      end

      def expected_total_ok?(expected_total)
        return true if expected_total.blank?

        @order.total == BigDecimal(expected_total)
      end
    end
  end
end
