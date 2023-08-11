# frozen_string_literal: true

module Spree
  module Admin
    class TaxonomiesController < ResourceController
      private

      def location_after_save
        if @taxonomy.created_at == @taxonomy.updated_at
          edit_admin_taxonomy_url(@taxonomy)
        else
          admin_taxonomies_url
        end
      end

      def destroy
        @taxonomy = Spree::Taxonomy.find(params[:id])
        @taxonomy.destroy
        respond_with(@taxonomy) { |format| format.json { render json: '' } }
      end
    end
  end
end
