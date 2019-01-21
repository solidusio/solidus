# frozen_string_literal: true

require 'active_storage'

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern

  module IOAttachmentSupport
    extend ActiveSupport::Concern

    def attachment=(attachable)
      case attachable
      when ActiveStorage::Blob, ActionDispatch::Http::UploadedFile,
           Rack::Test::UploadedFile, Hash, String
        super
      when ActiveStorage::Attached
        super(attachable.blob)
      else # assume it's an IO
        if attachable.respond_to?(:to_path)
          filename = attachable.to_path
        else
          filename = SecureRandom.uuid
        end
        attachable.rewind

        super(
          io: attachable,
          filename: filename
        )
      end
    end
  end

  included do
    has_one_attached :attachment

    validates :attachment, presence: true
    validate :attachment_is_an_image

    # This needs to be prepended in order to override the
    # accessor (#attachment=) defined by ActiveStorage.
    prepend IOAttachmentSupport
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

  def attachment_is_an_image
    errors.add :attachment, 'is not an image' unless attachment.try(:attachment).try(:image?)
  end

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
