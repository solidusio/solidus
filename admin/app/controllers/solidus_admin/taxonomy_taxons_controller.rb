# frozen_string_literal: true

module SolidusAdmin
  class TaxonomyTaxonsController < SolidusAdmin::BaseController
    include SolidusAdmin::Moveable

    before_action :load_taxonomy, only: [:new, :create]

    def new
      parent = @taxonomy.taxons.find_by(id: params[:parent_id]) || @taxonomy.root
      render new_component(@taxonomy.taxons.build(parent:))
    end

    def create
      taxon = @taxonomy.taxons.build(taxon_params)
      taxon.parent = @taxonomy.taxons.find_by(id: taxon.parent_id) || @taxonomy.root

      if taxon.save
        redirect_to solidus_admin.taxonomy_path(@taxonomy), status: :see_other, notice: t(".success")
      else
        component = new_component(taxon)
        respond_to do |format|
          format.html { render component, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(:taxon_form, component), status: :unprocessable_entity
          end
        end
      end
    end

    def move
      parent = params[:parent_id] ? @taxonomy.taxons.find(params[:parent_id]) : @moveable.parent
      @moveable.move_to_child_with_index(parent, params.require(:position).to_i - 1)
      @moveable.reload.update_permalinks

      render_tree
    end

    def destroy
      @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
      taxon = @taxonomy.taxons.where.not(parent_id: nil).find(params[:id])
      authorize! :destroy, taxon

      Spree::Taxon.transaction do
        taxon.children.reverse_each do |child|
          child.move_to_right_of(taxon)
          child.reload.update_permalinks
        end
        taxon.reload.destroy!
      end

      render_tree
    end

    private

    def load_taxonomy
      @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
    end

    def new_component(taxon)
      component("taxons/new").new(
        taxon:,
        url: solidus_admin.taxonomy_taxons_path(@taxonomy),
        frame: :taxon_form,
        target: "_top",
        taxonomy: @taxonomy
      )
    end

    def taxon_params
      params.require(:taxon).permit(:name, :parent_id, :description)
    end

    def render_tree
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @taxonomy.root,
            component("taxonomies/show/taxon").new(taxon: @taxonomy.root, taxonomy: @taxonomy, prefix: "1")
          )
        end
      end
    end

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
