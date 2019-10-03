# frozen_string_literal: true

module Solidus
  module Gallery
    class ProductGallery
      def initialize(product)
        @product = product
      end

      # A list of all images associated with this gallery
      #
      # @return [Enumerable<Solidus::Image>] all images in the gallery
      def images
        @images ||= @product.variant_images
      end
    end
  end
end
