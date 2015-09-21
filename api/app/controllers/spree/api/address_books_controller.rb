module Spree
  module Api
    class AddressBooksController < Spree::Api::BaseController
      # Note: the AddressBook is the resource to think about here, not individual addresses

      def show
        render_address_book
      end

      def update
        address_params = address_book_params
        default_flag = address_params.delete(:default)
        address = current_api_user.save_in_address_book(address_params, default_flag)
        if address.valid?
          render_address_book
        else
          invalid_resource!(address)
        end
      end

      def destroy
        current_api_user.remove_from_address_book(params[:address_id])
        render_address_book
      end

      private

      def render_address_book
        @user_addresses = current_api_user.user_addresses
        render :show, status: :ok
      end

      def address_book_params
        params.require(:address_book).permit(permitted_address_book_attributes)
      end
    end
  end
end
