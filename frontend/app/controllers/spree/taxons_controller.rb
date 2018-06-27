# frozen_string_literal: true

module Spree
  class TaxonsController < Spree::StoreController
    helper 'spree/products', 'spree/taxon_filters'

    before_action :load_taxon, only: [:show]

    respond_to :html

    def show
      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    private

    def load_taxon
      @taxon = Spree::Taxon.find_by!(permalink: params[:id])
    end

    def accurate_title
      if @taxon
        @taxon.seo_title
      else
        super
      end
    end
  end
end
