# frozen_string_literal: true

require 'active_storage'

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAttachment

  included do
    has_one_attached :attachment
    redefine_attachment_writer_with_legacy_io_support :attachment
    validate_attachment_to_be_an_image :attachment
    validates :attachment, presence: true
  end

  class_methods do
    def attachment_definitions
      { attachment: { styles: ATTACHMENT_STYLES } }
    end
  end

  ATTACHMENT_STYLES = {
    mini: '48x48>',
    small: '100x100>',
    product: '240x240>',
    large: '600x600>',
  }

  def default_style
    :original
  end

  def url(style = default_style, options = {})
    return unless attachment && attachment.attachment

    style = style.to_sym
    options = normalize_url_options(options)

    if style == default_style
      attachment_variant = attachment
    else
      attachment_variant = attachment.variant(
        resize: ATTACHMENT_STYLES[style.to_sym],
        strip: true,
        'auto-orient': true,
        colorspace: 'sRGB',
      ).processed
    end

    attachment_variant.service_url(options)
  end

  def filename
    attachment.blob.filename.to_s
  end

  def attachment_width
    attachment.metadata[:width]
  end

  def attachment_height
    attachment.metadata[:height]
  end

  def attachment_present?
    attachment.attached?
  end

  private

  def normalize_url_options(options)
    if [true, false].include? options # Paperclip backwards compatibility.
      Spree::Deprecation.warn(
        "Using #{self.class}#url with true/false as second parameter is deprecated, if you "\
        "want to enable/disable timestamps pass `timestamps: true` (or `false`)."
      )
      options = { timestamp: options }
    end

    options
  end
end
