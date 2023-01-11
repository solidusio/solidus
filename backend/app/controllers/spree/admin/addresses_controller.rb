module Spree
  module Admin
    class AddressesController < Spree::Admin::BaseController
      before_action :load_user

      def edit
        render 'addresses'
      end

      def update
        return unless @user

        new_shipping_address = Spree::Address.immutable_merge(@user.ship_address, user_params[:ship_address_attributes])
        new_bill_address = Spree::Address.immutable_merge(@user.bill_address, user_params[:bill_address_attributes])

        if (new_shipping_address.valid? && new_bill_address.valid?)
          @user.bill_address = new_bill_address
          @user.ship_address = new_shipping_address

          flash.now[:success] = t('spree.account_updated')
          redirect_to :admin_user_addresses
        else
          flash.now[:error] = message_validation_errors_for_addresses(new_bill_address, new_shipping_address)
          render "addresses"
        end
      end

      private

      def load_user
        @user = Spree.user_class.find_by(id: params[:user_id]) if params[:user_id]
      end

      def user_params
        attributes = permitted_user_attributes

        params.require(:user).permit(attributes)
      end

      def message_validation_errors_for_addresses(bill_address, ship_address)
        message = "Validation errors: </br>"
        if(!bill_address.valid?)
          message = message + "Billing address errors: #{map_errors(bill_address.errors.messages)} <br/>"
        end

        if(!ship_address.valid?)
          message = message + "Shipping address errors: #{map_errors(ship_address.errors.messages)}<br/>"
        end

        message.html_safe
      end

      def map_errors(errors)
        message = ""
        errors.each do |e|
          message = message + " #{e[0]} #{e[1].join(", ")}"
        end

        message
      end

      def load_roles
        @roles = Spree::Role.accessible_by(current_ability)
        if @user
          @user_roles = @user.spree_roles
        end
      end
    end
  end
end
