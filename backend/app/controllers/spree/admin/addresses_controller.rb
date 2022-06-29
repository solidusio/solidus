module Spree
  module Admin
    class AddressesController < Spree::Admin::BaseController
      def addresses
        @user = Spree.user_class.find_by(id: params[:user_id]) if params[:user_id]

        if request.put?
          begin
            new_shipping_address = Spree::Address.immutable_merge(@user.ship_address, user_params[:ship_address_attributes])
            new_bill_address = Spree::Address.immutable_merge(@user.bill_address, user_params[:bill_address_attributes])

            @user.bill_address = new_bill_address
            @user.ship_address = new_shipping_address
          rescue ActiveModel::StrictValidationFailed => e
            flash.now[:error] = e.message
            return render :addresses
          end

          flash.now[:success] = t('spree.account_updated')
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
    end
  end
end
