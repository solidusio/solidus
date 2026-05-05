# frozen_string_literal: true

module SolidusPaypalCommercePlatform
  class WizardController < ::Spree::Api::BaseController
    helper ::Spree::Core::Engine.routes.url_helpers

    def create
      authorize! :create, ::Spree::PaymentMethod

      @payment_method = ::Spree::PaymentMethod.new(payment_method_params)

      if @payment_method.save
        edit_url = spree.edit_admin_payment_method_url(@payment_method)

        render(
          json: { redirectUrl: edit_url },
          status: :created,
          location: edit_url,
          notice: "The PayPal Commerce Platform payment method has been successfully created"
        )
      else
        render json: @payment_method.errors, status: :unprocessable_entity
      end
    end

    private

    def payment_method_params
      {
        name: "PayPal Commerce Platform",
        type: SolidusPaypalCommercePlatform::PaymentMethod,
        preferred_client_id: api_credentials.client_id,
        preferred_client_secret: api_credentials.client_secret,
        preferred_test_mode: SolidusPaypalCommercePlatform.config.env.sandbox?,
        available_to_admin: false,
      }
    end

    def api_credentials
      @api_credentials ||= SolidusPaypalCommercePlatform::Client.fetch_api_credentials(
        auth_code: params.fetch(:authCode),
        client_id: params.fetch(:sharedId),
        nonce: params.fetch(:nonce),
      )
    end
  end
end
