# frozen_string_literal: true

module Spree
  module Api
    class CustomerReturnsController < Spree::Api::BaseController
      before_action :load_order
      before_action :build_customer_return, only: [:create]
      around_action :lock_order, only: [:create, :update, :destroy, :cancel]

      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      def create
        authorize! :create, CustomerReturn

        if @customer_return.save
          respond_with(@customer_return, status: 201, default_template: :show)
        else
          invalid_resource!(@customer_return)
        end
      end

      def index
        authorize! :index, CustomerReturn

        @customer_returns = @order.
          customer_returns.
          accessible_by(current_ability).
          ransack(params[:q]).
          result

        @customer_returns = paginate(@customer_returns)

        respond_with(@customer_returns)
      end

      def new
        authorize! :new, CustomerReturn
      end

      def show
        authorize! :show, CustomerReturn
        @customer_return = @order.customer_returns.accessible_by(current_ability, :show).find(params[:id])
        respond_with(@customer_return)
      end

      def update
        authorize! :update, CustomerReturn
        @customer_return = @order.customer_returns.accessible_by(current_ability, :update).find(params[:id])
        if @customer_return.update(customer_return_params)
          respond_with(@customer_return.reload, default_template: :show)
        else
          invalid_resource!(@customer_return)
        end
      end

      private

      def load_order
        @order ||= Spree::Order.find_by!(number: order_id)
        authorize! :show, @order
      end

      def customer_return_params
        params.require(:customer_return).permit(permitted_customer_return_attributes)
      end

      def build_customer_return
        customer_return_attributes = customer_return_params
        return_items_params = customer_return_attributes.
          delete(:return_items_attributes)

        @customer_return = CustomerReturn.new(customer_return_attributes)

        @customer_return.return_items = return_items_params.map do |item_params|
          return_item = if item_params[:id]
                          Spree::ReturnItem.find(item_params[:id])
                        else
                          Spree::ReturnItem.new
                        end

          return_item.assign_attributes(item_params)

          return_item
        end
      end
    end
  end
end
