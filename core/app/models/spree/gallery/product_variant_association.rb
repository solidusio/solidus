module Spree
  # Uses the ActiveRecord association for a Prodcut's Variant's Images
  module Gallery
    class ProductVariantAssociation < Gallery::Base

      # Creates a gallery for the given product
      # @param [Spree::Product] product The product to create the gallery for
      def initialize(product)
        @product = product
      end

      # (see Spree::Gallery#images)
      def images
        product.variant_images
      end

      # (see Spree::Gallery#primary_image)
      def primary_image
        product.images.first || product.variant_images.first
      end

      # Returns the primary image for the gallery
      #
      # Does not follow any fallback rules
      #
      # (see Spree::Gallery#best_image)
      def best_image
        primary_image
      end

      # Return a list of image associations to preload a Spree::Product's images
      #
      # @return An array compatible with ActiveRecord :includes
      #   for a Spree::Products images preload
      #
      # (see Spree::Galery#preload_params)
      def self.preload_params
        [:variant_images]
      end

      private
      attr_reader :product

    end
  end
end
