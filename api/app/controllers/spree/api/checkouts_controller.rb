# frozen_string_literal: true

module Spree
  module Api
    class CheckoutsController < Spree::Api::BaseController
      before_action :load_order, only: [:next, :advance, :update, :complete]
      around_action :lock_order, only: [:next, :advance, :update, :complete]
      before_action :update_order_state, only: [:next, :advance, :update, :complete]

      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      include Spree::Core::ControllerHelpers::Order

      # TODO: Remove this after deprecated usage in #update is removed
      include Spree::Core::ControllerHelpers::PaymentParameters

      def next
        authorize! :update, @order, order_token
        if !expected_total_ok?(params[:expected_total])
          respond_with(@order, default_template: 'spree/api/orders/expected_total_mismatch', status: 400)
          return
        end
        authorize! :update, @order, order_token
        @order.next!
        respond_with(@order, default_template: 'spree/api/orders/show', status: 200)
      rescue StateMachines::InvalidTransition => error
        logger.error("invalid_transition #{error.event} from #{error.from} for #{error.object.class.name}. Error: #{error.inspect}")
        respond_with(@order, default_template: 'spree/api/orders/could_not_transition', status: 422)
      end

      def advance
        authorize! :update, @order, order_token
        @order.contents.advance
        respond_with(@order, default_template: 'spree/api/orders/show', status: 200)
      end

      def complete
        authorize! :update, @order, order_token
        if !expected_total_ok?(params[:expected_total])
          respond_with(@order, default_template: 'spree/api/orders/expected_total_mismatch', status: 400)
        else
          @order.complete!
          respond_with(@order, default_template: 'spree/api/orders/show', status: 200)
        end
      rescue StateMachines::InvalidTransition => error
        logger.error("invalid_transition #{error.event} from #{error.from} for #{error.object.class.name}. Error: #{error.inspect}")
        respond_with(@order, default_template: 'spree/api/orders/could_not_transition', status: 422)
      end

      def update
        authorize! :update, @order, order_token

        if OrderUpdateAttributes.new(@order, update_params, request_env: request.headers.env).apply
          if can?(:admin, @order) && user_id.present?
            @order.associate_user!(Spree.user_class.find(user_id))
          end

          return if after_update_attributes

          if @order.completed? || @order.next
            state_callback(:after)
            respond_with(@order, default_template: 'spree/api/orders/show')
          else
            logger.error("failed_to_transition_errors=#{@order.errors.full_messages}")
            respond_with(@order, default_template: 'spree/api/orders/could_not_transition', status: 422)
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
        if update_params = massaged_params[:order]
          update_params.permit(permitted_checkout_attributes)
        else
          # We current allow update requests without any parameters in them.
          {}
        end
      end

      def massaged_params
        massaged_params = params.deep_dup

        set_payment_parameters_amount(massaged_params, @order)

        massaged_params
      end

      # Should be overriden if you have areas of your checkout that don't match
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
        if params[:order] && params[:order][:coupon_code].present?
          Spree::Deprecation.warn('This method is deprecated. Please use `Spree::Api::CouponCodesController#create` endpoint instead.')
          handler = PromotionHandler::Coupon.new(@order)
          handler.apply

          if handler.error.present?
            @coupon_message = handler.error
            respond_with(@order, default_template: 'spree/api/orders/could_not_apply_coupon', status: 422)
            return true
          end
        end
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
