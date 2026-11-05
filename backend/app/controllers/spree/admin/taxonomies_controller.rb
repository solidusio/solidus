# frozen_string_literal: true

module Spree
  module Admin
    class TaxonomiesController < ResourceController
      private

      def permitted_resource_params
        params.require(:taxonomy).permit(permitted_taxonomy_attributes)
      end

      def location_after_save
        if @taxonomy.created_at == @taxonomy.updated_at
          edit_admin_taxonomy_url(@taxonomy)
        else
          admin_taxonomies_url
        end
      end
    end
  end
end
