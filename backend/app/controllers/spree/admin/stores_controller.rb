# frozen_string_literal: true

module Spree
  module Admin
    class StoresController < Spree::Admin::ResourceController
      def index
        if Spree::Store.count == 1
          redirect_to edit_admin_store_path(Spree::Store.first)
        else
          @stores = Spree::Store.all
        end
      end

      private

      def permitted_resource_params
        super.tap do |store_params|
          without_address_parameters = store_params[:address_attributes]&.except(:country_id, :state_id, :reverse_charge_status)&.compact_blank&.empty?
          store_params.delete(:address_attributes) if without_address_parameters
        end
      end

      def store_params
        params.require(:store).permit(permitted_params)
      end

      def permitted_params
        Spree::PermittedAttributes.store_attributes
      end
    end
  end
end
