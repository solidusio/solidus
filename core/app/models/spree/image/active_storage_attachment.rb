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
                   styles: {
                   mini: '48x48>',
                   small: '400x400>',
                   product: '680x680>',
                   large: '1200x1200>'
                 },
                 default_style: :product

    def supported_content_type
      unless attachment.content_type.in?(Spree::Config.allowed_image_mime_types)
        errors.add(:attachment, :content_type_not_supported)
      end
    end
  end
end
