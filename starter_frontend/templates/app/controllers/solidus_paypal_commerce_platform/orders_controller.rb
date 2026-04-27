# frozen_string_literal: true

module SolidusPaypalCommercePlatform
  class OrdersController < ::Spree::Api::BaseController
    skip_before_action :authenticate_user
    include ::Spree::Core::ControllerHelpers::Auth

    def create
      authorize! :create, ::Spree::Order

      @order = ::Spree::Order.create!(
        user: current_api_user,
        store: current_store,
        currency: current_pricing_options.currency
      )

      if @order.contents.update_cart order_params
        # Overriding any existing orders
        cookies.signed[:guest_token] = @order.guest_token
        render json: @order, status: :ok
      else
        render json: @order.errors.full_messages, status: :unprocessable_entity
      end
    end

    def update_address
      load_order
      authorize! :update, @order, order_token
      paypal_address = SolidusPaypalCommercePlatform::PaypalAddress.new(@order)

      if paypal_address.update(paypal_address_params).valid?
        @order.ensure_updated_shipments
        @order.contents.advance
        render json: {}, status: :ok
      else
        render json: paypal_address.errors.full_messages, status: :unprocessable_entity
      end
    end

    def verify_total
      load_order
      authorize! :show, @order, order_token

      if total_is_correct?(params[:paypal_total])
        render json: {}, status: :ok
      else
        respond_with(@order, default_template: 'spree/api/orders/expected_total_mismatch', status: 400)
      end
    end

    private

    def total_is_correct?(paypal_total)
      @order.total == BigDecimal(paypal_total)
    end

    def paypal_address_params
      params.require(:address).permit(
        updated_address: [
          :address_line_1,
          :address_line_2,
          :admin_area_1,
          :admin_area_2,
          :postal_code,
          :country_code,
        ],
        recipient: [
          :email_address,
          {
            name: [
              :given_name,
              :surname,
            ]
          }
        ]
      )
    end

    def order_params
      params.require(:order).permit(permitted_order_attributes)
    end

    def load_order
      @order = ::Spree::Order.find_by!(number: params[:order_id])
    end
  end
end
