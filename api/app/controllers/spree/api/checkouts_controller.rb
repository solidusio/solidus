module Spree
  module Api
    class CheckoutsController < Spree::Api::BaseController
      before_filter :load_order, only: [:next, :advance, :complete]
      around_filter :lock_order, only: [:next, :advance, :complete]
      before_filter :update_order_state, only: [:next, :advance]

      rescue_from Spree::LineItem::InsufficientStock, with: :insufficient_stock_for_line_items

      include Spree::Core::ControllerHelpers::Auth

      def next
        authorize! :update, @order, order_token
        @order.next!
        respond_with(@order, default_template: 'spree/api/orders/show', status: 200)
      rescue StateMachine::InvalidTransition
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
      rescue StateMachine::InvalidTransition
        respond_with(@order, default_template: 'spree/api/orders/could_not_transition', status: 422)
      end

      private

        def load_order
          @order = Spree::Order.find_by!(number: params[:id])
          raise_insufficient_quantity and return if @order.insufficient_stock_lines.present?
        end

        def update_order_state
          @order.state = params[:state] if params[:state]
          state_callback(:before)
        end

        def raise_insufficient_quantity
          respond_with(@order, default_template: 'spree/api/orders/insufficient_quantity')
        end

        # TODO: Remove this?  The 'after' version was only called in #update and
        # #update has been removed.
        def state_callback(before_or_after = :before)
          method_name = :"#{before_or_after}_#{@order.state}"
          send(method_name) if respond_to?(method_name, true)
        end

        def order_id
          super || params[:id]
        end

        def expected_total_ok?(expected_total)
          return true if expected_total.blank?
          @order.total == BigDecimal(expected_total)
        end

        def insufficient_stock_for_line_items(exception)
          render json: { errors: ["Quantity is not available for items in your order"], type: 'insufficient_stock' }, status: 422
        end
    end
  end
end
