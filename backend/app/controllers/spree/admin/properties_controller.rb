# frozen_string_literal: true

module Spree
  module Admin
    class PropertiesController < ResourceController
      before_action :set_breadcrumbs

      def index
        respond_with(@collection)
      end

      private

      def collection
        return @collection if @collection
        # params[:q] can be blank upon pagination
        params[:q] = {} if params[:q].blank?

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result.
              page(params[:page]).
              per(Spree::Config[:properties_per_page])

        @collection
      end

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Product), spree.admin_products_path
        add_breadcrumb plural_resource_name(Spree::Property), spree.admin_properties_path
        add_breadcrumb @property.name if action_name == 'edit'
      end
    end
  end
end
