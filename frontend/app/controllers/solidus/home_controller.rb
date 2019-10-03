# frozen_string_literal: true

module Solidus
  class HomeController < Solidus::StoreController
    helper 'solidus/products'
    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Solidus::Taxonomy.includes(root: :children)
    end
  end
end
