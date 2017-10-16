module Spree
  class TaxonsController < Spree::StoreController
    helper 'spree/products'

    respond_to :html

    def show
      @taxon = Spree::Taxon.find_by!(permalink: params[:id])
      return unless @taxon

      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true).reject { |k, _| ["per_page", "page"].include?(k) } )
      @products = @searcher.retrieve_products.page(params[:page] || 1).per(params[:per_page].presence || Spree::Config[:products_per_page])
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
