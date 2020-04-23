# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class WalletPaymentsController < Spree::Admin::BaseController
        def index
          @wallet_payments = user.wallet.wallet_payment_sources
        end

        private

        def user
          @user ||= Spree.user_class.find(params[:user_id])
        end

        def model_class
          Spree::Wallet
        end
      end
    end
  end
end
