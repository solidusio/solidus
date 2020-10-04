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

      def store_params
        params.require(:store).permit(permitted_params)
      end

      def permitted_params
        Spree::PermittedAttributes.store_attributes
      end
    end
  end
end
