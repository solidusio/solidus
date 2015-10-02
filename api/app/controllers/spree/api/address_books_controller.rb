module Spree
  module Api
    class AddressBooksController < Spree::Api::BaseController
      # Note: the AddressBook is the resource to think about here, not individual addresses
      before_filter :load_user_addresses

      def show
        authorize! :show, address_book_user

        render :show, status: :ok
      end

      def update
        authorize! :save_in_address_book, address_book_user

        address_params = address_book_params
        default_flag = address_params.delete(:default)
        address = address_book_user.save_in_address_book(address_params, default_flag)
        if address.valid?
          render :show, status: :ok
        else
          invalid_resource!(address)
        end
      end

      def destroy
        authorize! :remove_from_address_book, address_book_user

        address_book_user.remove_from_address_book(params[:address_id])
        render :show, status: :ok
      end

      private

      def address_book_user
        @address_book_user ||= Spree.user_class.find(params[:user_id])
      end

      def load_user_addresses
        @user_addresses ||= address_book_user.user_addresses
      end

      def address_book_params
        params.require(:address_book).permit(permitted_address_book_attributes)
      end
    end
  end
end
