module Spree
  module Gallery

    # A gallery represents a collection of images.
    #
    # @abstract base class for all galleries. Implement your own
    #   to define how images should be associated to objects in your
    #   store
    class Base

      # A list of all images associated with this gallery
      #
      # @return [Enumerable<Spree::Image>] All images associated to the gallery
      def images; raise NotImplementedError end

      # The "primary" {Spree::Image} associated with the gallery
      #
      # Typically the most appropriate single image to display representing
      # the gallery, but will not follow the fallback rules of {#best_image}
      #
      # @return [Spree::Image, nil] if primary image for the gallery exists or
      #   nil otherwise
      #
      # @abstract
      def primary_image; raise NotImplementedError end

      # The "best" {Spree::Image} associated with this gallery.
      #
      # Will attempt to fall back to other sources and logic to find a picture
      # if the {#primary_image} does not exist
      #
      # @return [Spree::Image, nil] if an image can be found to represent the gallery,
      #   following fallback rules, and nli otherwise
      #
      # @abstract
      def best_image; raise NotImplementedError end

      # Return an ActiveRecord-compatible Array of objects to preload
      #
      # An unfortunate method to allow the application to minimize queries while
      # allowing different Gallery implementations to maintain their own
      # database structures
      #
      # @return [Array] an ActiveRecord::QueryMethods#includes compatible array
      def self.preload_params
        []
      end

    end
  end
end
