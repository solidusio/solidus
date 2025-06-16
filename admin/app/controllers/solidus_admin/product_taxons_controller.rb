# frozen_string_literal: true

module SolidusAdmin
  class ProductTaxonsController < SolidusAdmin::BaseController
    before_action :load_product, only: [:new, :create]

    def new
      render component("products/show/categories/new").new(product: @product)
    end

    def create
      init_taxon
      root_taxon! if @taxon.root?
      @product.taxons << @taxon

      respond_to do |format|
        format.html { redirect_to @product, status: :see_other, notice: t(".success") }
      end
    rescue ActiveRecord::RecordInvalid
      component = component("products/show/categories/new").new(product: @product, taxon: @taxon)
      respond_to do |format|
        format.html { render component, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(:new_product_category, component),
          status: :unprocessable_entity
        end
      end
    end

    private

    def load_product
      @product = Spree::Product.friendly.find(params[:product_id])
    end

    def init_taxon
      @taxon = Spree::Taxon.new(category_params)
      @taxon.taxonomy_id = @taxon.parent&.taxonomy_id
    end

    # Parent-less taxons must be associated with a taxonomy of the same name; it's guaranteed that in order to create a
    # new parent-less taxon we need to create a new taxonomy.
    def root_taxon!
      # if Taxonomy.create! fails on the next step, we need validation errors on taxon object
      # to display them on the form
      @taxon.validate
      Spree::Taxonomy.create!(name: @taxon.name, root: @taxon)
    end

    def authorization_subject
      Spree::Classification
    end

    def category_params
      params.require(:taxon).permit(:name, :parent_id, :description)
    end
  end
end
