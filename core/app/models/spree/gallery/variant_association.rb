module Spree
  # Uses the ActiveRecord association between Spree::Variant and
  #   Spree::Image
  module Gallery
    class VariantAssociation < Gallery::Base

      # Creates a gallery for the given variant
      # @param [Spree::Variant] variant variant to build the gallery for
      def initialize(variant)
        @variant = variant
      end

      # (see Spree::Gallery#images)
      def images
        variant.images
      end

      # (see Spree::Gallery#primary_image)
      def primary_image
        variant.images.first
      end

      # Will fall back to the first image on the variant's product if
      # the variant has no associated images.
      # @return [Spree::Image, nil] The variant's primary image, if it exists,
      #   or the variant's products first image, if it exists, nil otherwise
      def best_image
        primary_image || products_images.first
      end

      # Return a list of image associations to preload a Spree::Variant's images
      #
      # @return An array compatible with ActiveRecord :includes
      #   for a Spree::Variant images preload
      #
      # (see Spree::Galery#preload_params)
      def self.preload_params
        [:images]
      end

      private
      attr_reader :variant

      def products_images
        variant.product.try!(:variant_images) || []
      end

    end
  end
end
