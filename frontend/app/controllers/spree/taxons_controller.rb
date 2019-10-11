# frozen_string_literal: true

module Solidus
  class TaxonsController < Solidus::StoreController
    helper 'solidus/products', 'solidus/taxon_filters'

    before_action :load_taxon, only: [:show]

    respond_to :html

    def show
      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Solidus::Taxonomy.includes(root: :children)
    end

    private

    def load_taxon
      @taxon = Solidus::Taxon.find_by!(permalink: params[:id])
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
