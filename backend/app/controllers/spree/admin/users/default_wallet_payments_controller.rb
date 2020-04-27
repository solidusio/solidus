# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class DefaultWalletPaymentsController < Spree::Admin::BaseController
        def update
          user.wallet.default_wallet_payment_source = wallet_payment
          redirect_back fallback_location: admin_user_wallet_payments_path(user)
        end

        private

        def wallet_payment
          @wallet_payment = Spree::WalletPaymentSource.find(params[:wallet_payment_id])
        end

        def user
          wallet_payment.user
        end
      end
    end
  end
end
