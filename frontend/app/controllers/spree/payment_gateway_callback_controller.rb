# frozen_string_literal: true

module Spree
  class PaymentGatewayCallbackController < Spree::StoreController
    def confirm
      Spree::Config.payment_gateway_confirm_handler_class.new(params).call
    end

    def cancel
      Spree::Config.payment_gateway_cancel_handler_class.new(params).call
    end
  end
end
