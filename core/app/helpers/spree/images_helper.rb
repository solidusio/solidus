module Spree
  module ImagesHelper
    # Return the provided image if it is not nil,
    # otherwise return a default {Spree::Image}.
    #
    # This is useful when displaying images for a resource when it exists,
    # or falling back to the Paperclip default image when none is provided.
    #
    # @param image [Spree::Image, nil] The image to return, or nil if the default
    #   should be used.
    #
    # @return [Spree::Image] the provided image if it exists, or a default
    #   image otherwise
    def image_or_default(image)
      image || Spree::Image.new
    end
  end
end
