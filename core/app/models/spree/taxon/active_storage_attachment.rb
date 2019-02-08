# frozen_string_literal: true

require 'active_storage'

module Spree::Taxon::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAttachment

  included do
    has_one_attached :icon
    redefine_attachment_writer_with_legacy_io_support :icon
    validate_attachment_to_be_an_image :icon
  end

  def icon_present?
    icon.attached?
  end
end
