# frozen_string_literal: true

module Spree
  module Admin
    class TaxonomiesController < ResourceController
      before_action :set_breadcrumbs

      private

      def location_after_save
        if @taxonomy.created_at == @taxonomy.updated_at
          edit_admin_taxonomy_url(@taxonomy)
        else
          admin_taxonomies_url
        end
      end

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Product), spree.admin_products_path
        add_breadcrumb plural_resource_name(Spree::Taxonomy), spree.admin_taxonomies_path
        add_breadcrumb @taxonomy.name          if action_name == 'edit'
        add_breadcrumb t('spree.new_taxonomy') if action_name == 'new'
      end
    end
  end
end
