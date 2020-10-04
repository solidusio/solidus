# frozen_string_literal: true

module Spree
  module Api
    class AddressBooksController < Spree::Api::BaseController
      # Note: the AddressBook is the resource to think about here, not individual addresses
      before_action :load_user_addresses

      def show
        authorize! :show, address_book_user

        render :show, status: :ok
      end

      # Update a user's address book by adding an address to it or by updating
      # the associated UserAddress (e.g. making it the default).
      #
      # @param user_id [String] the user id of the address book we're updating.
      # @param address_book [Hash] any key-values permitted by
      #   permitted_address_book_attributes
      # @return [Array] *All* of the user's addresses, since the resource here
      #   is the address book and since we may have mutated other UserAddresses
      #   (e.g. changed the 'default' flag).  The user's default address will be
      #   flagged with default=true and the target address from this update will
      #   be flagged with update_target=true.
      def update
        authorize! :save_in_address_book, address_book_user

        address_params = address_book_params
        default_flag = address_params.delete(:default)
        @address = address_book_user.save_in_address_book(address_params, default_flag)
        if @address.valid?
          render :show, status: :ok
        else
          invalid_resource!(@address)
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
