# frozen_string_literal: true

module Spree
  module Api
    class AddressesController < Spree::Api::BaseController
      before_action :find_order

      def show
        authorize! :read, @order, order_token
        find_address
        respond_with(@address)
      end

      def update
        authorize! :update, @order, order_token
        find_address

        if @order.update({ "#{@order_source}_attributes" => address_params })
          @address = @order.send(@order_source)
          respond_with(@address, default_template: :show)
        else
          @address = @order.send(@order_source)
          invalid_resource!(@address)
        end
      end

      private

      def address_params
        params.require(:address).permit(permitted_address_attributes)
      end

      def find_order
        @order = Spree::Order.find_by!(number: order_id)
      end

      def find_address
        @address = if @order.bill_address_id == params[:id].to_i
          @order_source = :bill_address
          @order.bill_address
        elsif @order.ship_address_id == params[:id].to_i
          @order_source = :ship_address
          @order.ship_address
        else
          raise CanCan::AccessDenied
        end
      end
    end
  end
end
