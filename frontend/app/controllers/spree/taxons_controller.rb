# frozen_string_literal: true

module Spree
  class TaxonsController < Spree::StoreController
    helper 'spree/products', 'spree/taxon_filters'

    respond_to :html

    def show
      @taxon = Spree::Taxon.find_by!(permalink: params[:id])
      return unless @taxon

      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    private

    def accurate_title
      if @taxon
        @taxon.seo_title
      else
        super
      end
    end
  end
end
