module Spree
  module Admin
    class AddressesController < Spree::Admin::BaseController
      def addresses
        @user = Spree.user_class.find_by(id: params[:user_id]) if params[:user_id]

        render :addresses
      end

      def update
        @user = Spree.user_class.find_by(id: params[:user_id]) if params[:user_id]

        new_shipping_address = Spree::Address.immutable_merge(@user.ship_address, user_params[:ship_address_attributes])
        new_bill_address = Spree::Address.immutable_merge(@user.bill_address, user_params[:bill_address_attributes])

        if (new_shipping_address.valid? && new_bill_address.valid?)
          @user.bill_address = new_bill_address
          @user.ship_address = new_shipping_address

          flash.now[:success] = t('spree.account_updated')
        else
          flash.now[:error] = message_validation_errors_for_addresses(new_bill_address, new_shipping_address)
        end

        render :addresses
      end

      def model_class
        Spree.user_class
      end

      private

      def user_params
        attributes = permitted_user_attributes

        params.require(:user).permit(attributes)
      end

      def message_validation_errors_for_addresses(bill_address, ship_address)
        message = "Validation errors: "
        if(!bill_address.valid?)
          message = message + "Billing address errors: #{map_errors(bill_address.errors.messages)}"
        end

        if(!ship_address.valid?)
          message = message + "Shipping address errors: #{map_errors(ship_address.errors.messages)}"
        end

        message
      end

      def map_errors(errors)
        message = ""
        errors.each do |e|
          message = message + " #{e[0]} #{e[1].join(", ")}"
        end

        message
      end
    end
  end
end
