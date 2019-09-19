# frozen_string_literal: true

module Spree
  module Api
    class TaxonsController < Spree::Api::BaseController
      def index
        if taxonomy
          @taxons = taxonomy.root.children
        elsif params[:ids]
          @taxons = Spree::Taxon.accessible_by(current_ability, :read).where(id: params[:ids].split(','))
        else
          @taxons = Spree::Taxon.accessible_by(current_ability, :read).order(:taxonomy_id, :lft).ransack(params[:q]).result
        end

        unless params[:without_children]
          @taxons = @taxons.includes(:children)
        end

        @taxons = paginate(@taxons)
        preload_taxon_parents(@taxons)
        respond_with(@taxons)
      end

      def new
      end

      def show
        @taxon = taxon
        respond_with(@taxon)
      end

      def jstree
        Spree::Deprecation.warn("Please don't use `/api/taxonomies/:taxonomy_id/taxons/:taxon_id/jstree` endpoint. It is deprecated and will be removed in the next future.", caller)
        show
      end

      def create
        authorize! :create, Taxon
        @taxon = Spree::Taxon.new(taxon_params)
        @taxon.taxonomy_id = params[:taxonomy_id]
        taxonomy = Spree::Taxonomy.find_by(id: params[:taxonomy_id])

        if taxonomy.nil?
          @taxon.errors.add(:taxonomy_id, I18n.t('spree.api.invalid_taxonomy_id'))
          invalid_resource!(@taxon) && return
        end

        @taxon.parent_id = taxonomy.root.id unless params[:taxon][:parent_id]

        if @taxon.save
          respond_with(@taxon, status: 201, default_template: :show)
        else
          invalid_resource!(@taxon)
        end
      end

      def update
        authorize! :update, taxon
        if taxon.update(taxon_params)
          respond_with(taxon, status: 200, default_template: :show)
        else
          invalid_resource!(taxon)
        end
      end

      def destroy
        authorize! :destroy, taxon
        taxon.destroy
        respond_with(taxon, status: 204)
      end

      def products
        # Returns the products sorted by their position with the classification
        # Products#index does not do the sorting.
        taxon = Spree::Taxon.find(params[:id])
        @products = paginate(taxon.products.ransack(params[:q]).result)
        @products = @products.includes(master: :default_price)

        if params[:simple]
          @exclude_data = {
            variants: true,
            option_types: true,
            product_properties: true,
            classifications: true
          }
          @product_attributes = %i(id name display_price)
        end
        render "spree/api/products/index"
      end

      private

      def default_per_page
        500
      end

      def taxonomy
        if params[:taxonomy_id].present?
          @taxonomy ||= Spree::Taxonomy.accessible_by(current_ability, :read).find(params[:taxonomy_id])
        end
      end

      def taxon
        @taxon ||= taxonomy.taxons.accessible_by(current_ability, :read).find(params[:id])
      end

      def taxon_params
        if params[:taxon] && !params[:taxon].empty?
          params.require(:taxon).permit(permitted_taxon_attributes)
        else
          {}
        end
      end

      def preload_taxon_parents(taxons)
        parents = Spree::Taxon.none

        taxons.map do |taxon|
          parents = parents.or(taxon.ancestors)
        end

        Spree::Taxon.associate_parents(taxons + parents)
      end
    end
  end
end
