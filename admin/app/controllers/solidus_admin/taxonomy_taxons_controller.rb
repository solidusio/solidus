# frozen_string_literal: true

module SolidusAdmin
  class TaxonomyTaxonsController < SolidusAdmin::BaseController
    include SolidusAdmin::Moveable

    def move
      parent = params[:parent_id] ? @taxonomy.taxons.find(params[:parent_id]) : @moveable.parent
      @moveable.move_to_child_with_index(parent, params.require(:position).to_i - 1)
      @moveable.reload.update_permalinks

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @taxonomy.root,
            component("taxonomies/show/taxon").new(taxon: @taxonomy.root, taxonomy: @taxonomy, prefix: "1")
          )
        end
      end
    end

    private

    def load_moveable
      @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
      @moveable = @taxonomy.taxons.find(params.require(:id))
      authorize! action_name, @moveable
    end

    def moveable_class
      Spree::Taxon
    end

    def authorization_subject = Spree::Taxon
  end
end
