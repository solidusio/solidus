module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true).reject { |k, _| ["per_page", "page"].include?(k) } )
      @products = @searcher.retrieve_products.page(params[:page] || 1).per(params[:per_page].presence || Spree::Config[:products_per_page])
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end
  end
end
