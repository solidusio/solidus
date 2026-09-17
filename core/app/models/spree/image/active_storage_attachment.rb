# frozen_string_literal: true

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  delegate :width, :height, to: :attachment, prefix: true

  included do
    validates :attachment, presence: true
    validate :attachment_is_an_image
    validate :supported_content_type

    has_attachment :attachment,
      styles: Spree::Config.product_image_styles,
      default_style: Spree::Config.product_image_style_default

    def supported_content_type
      unless attachment.content_type.in?(Spree::Config.allowed_image_mime_types)
        errors.add(:attachment, :content_type_not_supported)
      end
    end
  end

  # Returns the preload tree needed to resolve image.url(style) and image.alt
  # without N+1 queries. Used by callers to nest preloads under image-bearing
  # associations on parent records, e.g.
  #   includes(variant_images: Spree::Image.attachment_preloads)
  #
  # We build this manually rather than delegating to with_attached_attachment
  # because Rails' generated scope includes a preview_image_attachment branch
  # that is only relevant for non-image files (PDFs, videos, etc.). Product
  # images never have previews, so including that branch loads empty result
  # sets from active_storage_attachments and active_storage_blobs on every
  # request for no benefit.
  def self.attachment_preloads = [
    {attachment_attachment: {blob: {variant_records: {image_attachment: :blob}}}}
  ]
end
