# frozen_string_literal: true

module Spree
  module Gallery
    class ProductGallery
      attr_reader :product

      def initialize(product)
        @product = product
      end

      # A list of all images associated with this gallery
      #
      # @return [Enumerable<Spree::Image>] all images in the gallery
      def images
        @images ||= product.variant_images.uniq + Spree::Image.for_variants(all_variants.map(&:id))
      end

      private

      def all_variants
        product.variants_including_master
      end
    end
  end
end
