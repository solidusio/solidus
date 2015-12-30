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

    # Display an image_tag for the given spree image, if one exists, for the
    # provided style, or a image_tag for the default image if no image is provided.
    #
    # @param image [Spree::Image, nil] The image to display, if provided, or nil
    # if the default image should be displayed.
    #
    # @param style [symbol] The paperclip {Spree::Image} style to display the image_tag
    # for
    #
    # @return [String] A string of the image_tag built from the provided image
    def spree_image_tag(image, style, options={})
      image_tag image_or_default(image).attachment(style), options
    end
  end
end
