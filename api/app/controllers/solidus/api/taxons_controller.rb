module Spree
  module Api
    class TaxonsController < Solidus::Api::BaseController
      def index
        if taxonomy
          @taxons = taxonomy.root.children
        else
          if params[:ids]
            @taxons = Solidus::Taxon.accessible_by(current_ability, :read).where(id: params[:ids].split(','))
          else
            @taxons = Solidus::Taxon.accessible_by(current_ability, :read).order(:taxonomy_id, :lft).ransack(params[:q]).result
          end
        end

        @taxons = @taxons.page(params[:page]).per(params[:per_page])
        respond_with(@taxons)
      end

      def show
        @taxon = taxon
        respond_with(@taxon)
      end

      def jstree
        show
      end

      def create
        authorize! :create, Taxon
        @taxon = Solidus::Taxon.new(taxon_params)
        @taxon.taxonomy_id = params[:taxonomy_id]
        taxonomy = Solidus::Taxonomy.find_by(id: params[:taxonomy_id])

        if taxonomy.nil?
          @taxon.errors[:taxonomy_id] = I18n.t(:invalid_taxonomy_id, scope: 'solidus.api')
          invalid_resource!(@taxon) and return
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
        if taxon.update_attributes(taxon_params)
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
        taxon = Solidus::Taxon.find(params[:id])
        @products = taxon.products.ransack(params[:q]).result
        @products = @products.page(params[:page]).per(params[:per_page] || 500)
        render "solidus/api/products/index"
      end

      private

        def taxonomy
          if params[:taxonomy_id].present?
            @taxonomy ||= Solidus::Taxonomy.accessible_by(current_ability, :read).find(params[:taxonomy_id])
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
    end
  end
end
