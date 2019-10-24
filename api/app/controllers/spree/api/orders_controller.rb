# frozen_string_literal: true

module Spree
  module Api
    class OrdersController < Spree::Api::BaseController
      class_attribute :admin_shipment_attributes
      self.admin_shipment_attributes = [:shipping_method, :stock_location, inventory_units: [:variant_id, :sku]]

      class_attribute :admin_order_attributes
      self.admin_order_attributes = [:import, :number, :completed_at, :locked_at, :channel, :user_id, :created_at]

      class_attribute :admin_payment_attributes
      self.admin_payment_attributes = [:payment_method, :amount, :state, source: {}]

      skip_before_action :authenticate_user, only: :apply_coupon_code

      before_action :find_order, except: [:create, :mine, :current, :index]
      around_action :lock_order, except: [:create, :mine, :current, :index, :show]

      # Dynamically defines our stores checkout steps to ensure we check authorization on each step.
      Spree::Order.checkout_steps.keys.each do |step|
        define_method step do
          authorize! :update, @order, params[:token]
        end
      end

      def cancel
        authorize! :update, @order, params[:token]
        @order.canceled_by(current_api_user)
        respond_with(@order, default_template: :show)
      end

      def create
        authorize! :create, Order

        if can?(:admin, Order)
          @order = Spree::Core::Importer::Order.import(determine_order_user, order_params)
          respond_with(@order, default_template: :show, status: 201)
        else
          @order = Spree::Order.create!(user: current_api_user, store: current_store)
          if @order.contents.update_cart order_params
            respond_with(@order, default_template: :show, status: 201)
          else
            invalid_resource!(@order)
          end
        end
      end

      def empty
        authorize! :update, @order, order_token
        @order.empty!
        render plain: nil, status: 204
      end

      def index
        authorize! :index, Order
        orders_includes = [
          { user: :store_credits },
          :line_items,
          :valid_store_credit_payments
        ]
        @orders = paginate(
          Spree::Order
            .ransack(params[:q])
            .result
            .includes(orders_includes)
        )
        respond_with(@orders)
      end

      def show
        authorize! :show, @order, order_token
        respond_with(@order)
      end

      def update
        authorize! :update, @order, order_token

        if @order.contents.update_cart(order_params)
          user_id = params[:order][:user_id]
          if can?(:admin, @order) && user_id
            @order.associate_user!(Spree.user_class.find(user_id))
          end
          respond_with(@order, default_template: :show)
        else
          invalid_resource!(@order)
        end
      end

      def current
        if current_api_user && @order = current_api_user.last_incomplete_spree_order(store: current_store)
          respond_with(@order, default_template: :show, locals: { root_object: @order })
        else
          head :no_content
        end
      end

      def mine
        if current_api_user
          @orders = current_api_user.orders.by_store(current_store).reverse_chronological.ransack(params[:q]).result
          @orders = paginate(@orders)
        else
          render "spree/api/errors/unauthorized", status: :unauthorized
        end
      end

      def apply_coupon_code
        Spree::Deprecation.warn('This method is deprecated. Please use `Spree::Api::CouponCodesController#create` endpoint instead.')

        authorize! :update, @order, order_token
        @order.coupon_code = params[:coupon_code]
        @handler = PromotionHandler::Coupon.new(@order).apply
        if @handler.successful?
          render "spree/api/promotions/handler", status: 200
        else
          logger.error("apply_coupon_code_error=#{@handler.error.inspect}")
          render "spree/api/promotions/handler", status: 422
        end
      end

      private

      def order_params
        if params[:order]
          normalize_params
          params.require(:order).permit(permitted_order_attributes)
        else
          {}
        end
      end

      def normalize_params
        params[:order][:payments_attributes] = params[:order].delete(:payments) if params[:order][:payments]
        params[:order][:shipments_attributes] = params[:order].delete(:shipments) if params[:order][:shipments]
        params[:order][:line_items_attributes] = params[:order].delete(:line_items) if params[:order][:line_items]
        params[:order][:ship_address_attributes] = params[:order].delete(:ship_address) if params[:order][:ship_address].present?
        params[:order][:bill_address_attributes] = params[:order].delete(:bill_address) if params[:order][:bill_address].present?
      end

      # @api public
      def determine_order_user
        if order_params[:user_id].present?
          Spree.user_class.find(order_params[:user_id])
        else
          current_api_user
        end
      end

      def permitted_order_attributes
        can?(:admin, Spree::Order) ? (super + admin_order_attributes) : super
      end

      def permitted_shipment_attributes
        if can?(:admin, Spree::Shipment)
          super + admin_shipment_attributes
        else
          super
        end
      end

      def permitted_payment_attributes
        if can?(:admin, Spree::Payment)
          super + admin_payment_attributes
        else
          super
        end
      end

      def find_order(_lock = false)
        @order = Spree::Order.
          includes(line_items: [:adjustments, { variant: :images }],
                   payments: :payment_method,
                   shipments: {
                     shipping_rates: { shipping_method: :zones, taxes: :tax_rate }
                   }).
          find_by!(number: params[:id])
      end

      def order_id
        super || params[:id]
      end
    end
  end
end
