# frozen_string_literal: true

module Spree
  module Admin
    class StoresController < Spree::Admin::ResourceController
      before_action :set_breadcrumbs

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

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Store), admin_stores_path
        add_breadcrumb t('spree.new_store') if action_name == 'new'
        add_breadcrumb @store.name if action_name == 'edit'
      end
    end
  end
end
