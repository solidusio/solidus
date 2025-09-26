# frozen_string_literal: true

module Spree
  class TaxonBrandSelector
    BRANDS_TAXONOMY_NAME = "Brands"

    def initialize(product)
      @product = product
    end

    def call
      product.taxons
        .joins(:taxonomy)
        .where(spree_taxonomies: {name: BRANDS_TAXONOMY_NAME})
        .first
    end

    private

    attr_reader :product
  end
end
