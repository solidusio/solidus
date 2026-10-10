# frozen_string_literal: true

module Spree::Store::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter::HasAttachments

  included do
    has_attachment :logo, styles: {}, default_style: :original
    has_attachment :favicon, styles: {}, default_style: :original

    validate :logo_is_an_image
    validate :favicon_is_an_image
    validate :supported_attachment_content_types
  end

  private

  def supported_attachment_content_types
    [:logo, :favicon].each do |name|
      attachment = public_send(name)
      next unless attachment.attached?
      next if attachment.content_type.in?(Spree::Config.allowed_image_mime_types)

      errors.add(name, :content_type_not_supported)
    end
  end
end
