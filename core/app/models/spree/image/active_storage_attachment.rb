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
end
