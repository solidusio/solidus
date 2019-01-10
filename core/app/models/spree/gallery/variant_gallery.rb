# frozen_string_literal: true

module Spree
  module Gallery
    class VariantGallery
      def initialize(variant)
        @variant = variant
      end

      # A list of all images associated with this gallery
      #
      # @return [Enumerable<Spree::Image>] all images in the gallery
      def images
        @images ||=
          @variant.images.presence ||
          (!@variant.is_master? && @variant.product.master.images).presence ||
          Spree::Image.none
      end
    end
  end
end
