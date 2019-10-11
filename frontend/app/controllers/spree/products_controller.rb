# frozen_string_literal: true

module Solidus
  class ProductsController < Solidus::StoreController
    before_action :load_product, only: :show
    before_action :load_taxon, only: :index

    helper 'solidus/taxons', 'solidus/taxon_filters'

    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Solidus::Taxonomy.includes(root: :children)
    end

    def show
      @variants = @product.
        variants_including_master.
        display_includes.
        with_prices(current_pricing_options).
        includes([:option_values, :images])

      @product_properties = @product.product_properties.includes(:property)
      @taxon = Solidus::Taxon.find(params[:taxon_id]) if params[:taxon_id]
    end

    private

    def accurate_title
      if @product
        @product.meta_title.blank? ? @product.name : @product.meta_title
      else
        super
      end
    end

    def load_product
      if try_spree_current_user.try(:has_spree_role?, "admin")
        @products = Solidus::Product.with_deleted
      else
        @products = Solidus::Product.available
      end
      @product = @products.friendly.find(params[:id])
    end

    def load_taxon
      @taxon = Solidus::Taxon.find(params[:taxon]) if params[:taxon].present?
    end
  end
end
