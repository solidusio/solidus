# frozen_string_literal: true

module Solidus
  module Admin
    class StoresController < Solidus::Admin::ResourceController
      def index
        if Solidus::Store.count == 1
          redirect_to edit_admin_store_path(Solidus::Store.first)
        else
          @stores = Solidus::Store.all
        end
      end

      private

      def store_params
        params.require(:store).permit(permitted_params)
      end

      def permitted_params
        Solidus::PermittedAttributes.store_attributes
      end
    end
  end
end
