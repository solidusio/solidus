# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class WalletPaymentsController < Spree::Admin::BaseController
        def index
          @wallet_payments = user.wallet.wallet_payment_sources
        end

        def destroy
          wallet_payment = user.wallet.find(params[:id])

          if wallet_payment
            user.wallet.remove(wallet_payment.payment_source)

            flash[:success] = flash_message_for(wallet_payment, :successfully_removed)
            respond_with(@object) do |format|
              format.html { redirect_to admin_user_wallet_payments_path(user) }
              format.js   { render partial: "spree/admin/shared/destroy" }
            end
          end
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
