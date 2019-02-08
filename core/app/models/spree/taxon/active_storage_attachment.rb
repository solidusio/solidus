# frozen_string_literal: true

require 'active_storage'

module Spree::Taxon::ActiveStorageAttachment
  extend ActiveSupport::Concern

  module IOAttachmentSupport
    extend ActiveSupport::Concern

    def icon=(attachable)
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
    has_one_attached :icon

    validate :icon_is_an_image

    # This needs to be prepended in order to override the
    # accessor (#icon=) defined by ActiveStorage.
    prepend IOAttachmentSupport
  end

  def icon_present?
    icon.attached?
  end

  private

  def icon_is_an_image
    errors.add :icon, 'is not an image' unless icon.try(:attachment).try(:image?)
  end
end
