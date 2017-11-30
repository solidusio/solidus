# frozen_string_literal: true

module Spree
  class Image < Asset
    validate :no_attachment_errors

    has_attached_file :attachment,
                      styles: { mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>' },
                      default_style: :product,
                      default_url: 'noimage/:style.png',
                      url: '/spree/products/:id/:style/:basename.:extension',
                      path: ':rails_root/public/spree/products/:id/:style/:basename.:extension',
                      convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
    validates_attachment :attachment,
      presence: true,
      content_type: { content_type: %w(image/jpeg image/jpg image/png image/gif) }

    # save the w,h of the original image (from which others can be calculated)
    # we need to look at the write-queue for images which have not been saved yet
    after_post_process :find_dimensions, if: :valid?

    def mini_url
      Spree::Deprecation.warn(
        'Spree::Image#mini_url is DEPRECATED. Use Spree::Image#url(:mini) instead.'
      )
      attachment.url(:mini, false)
    end

    def url(size)
      attachment.url(size)
    end

    def filename
      attachment_file_name
    end

    def find_dimensions
      temporary = attachment.queued_for_write[:original]
      filename = temporary.path unless temporary.nil?
      filename = attachment.path if filename.blank?
      geometry = Paperclip::Geometry.from_file(filename)
      self.attachment_width  = geometry.width
      self.attachment_height = geometry.height
    end

    # if there are errors from the plugin, then add a more meaningful message
    def no_attachment_errors
      unless attachment.errors.empty?
        # uncomment this to get rid of the less-than-useful interim messages
        # errors.clear
        errors.add :attachment, "Paperclip returned errors for file '#{attachment_file_name}' - check ImageMagick installation or image source file."
        false
      end
    end
  end
end
