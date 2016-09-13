module Spree
  module Admin
    module Orders
      class CustomerDetailsController < Spree::Admin::BaseController
        rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

        before_action :load_order

        def show
          edit
        end

        def edit
          country_id = Country.default.id
          @order.build_bill_address(country_id: country_id) if @order.bill_address.nil?
          @order.build_ship_address(country_id: country_id) if @order.ship_address.nil?

          @order.bill_address.country_id = country_id if @order.bill_address.country.nil?
          @order.ship_address.country_id = country_id if @order.ship_address.country.nil?
        end

        def update
          if @order.contents.update_cart(order_params)

            if should_associate_user?
              requested_user = Spree.user_class.find(params[:user_id])
              @order.associate_user!(requested_user, @order.email.blank?)
            end

            unless @order.completed?
              @order.next
              @order.refresh_shipment_rates
            end

            flash[:success] = Spree.t('customer_details_updated')
            redirect_to edit_admin_order_url(@order)
          else
            render action: :edit
          end
        end

        private

        def order_params
          params.require(:order).permit(
            :email,
            :use_billing,
            bill_address_attributes: permitted_address_attributes,
            ship_address_attributes: permitted_address_attributes
          )
        end

        def load_order
          @order = Order.includes(:adjustments).find_by_number!(params[:order_id])
        end

        def model_class
          Spree::Order
        end

        def should_associate_user?
          params[:guest_checkout] == "false" && params[:user_id] && params[:user_id].to_i != @order.user_id
        end

        def insufficient_stock_error
          flash[:error] = Spree.t(:insufficient_stock_for_order)
          redirect_to edit_admin_order_customer_url(@order)
        end
      end
    end
  end
end
