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
        @images ||= @variant.images
      end
    end
  end
end
