# frozen_string_literal: true

module SolidusPaypalCommercePlatform
  class PaypalOrdersController < ::Spree::Api::BaseController
    before_action :load_payment_method
    skip_before_action :authenticate_user

    def show
      authorize! :show, @order, order_token
      order_request = @payment_method.gateway.create_order(@order, @payment_method.auto_capture?)

      render json: order_request, status: order_request.status_code
    end

    private

    def load_payment_method
      @payment_method = ::Spree::PaymentMethod.find(params.require(:payment_method_id))
    end
  end
end
