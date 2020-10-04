# frozen_string_literal: true

module Spree::Taxon::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  included do
    has_attachment :icon,
                   styles: { mini: '32x32>', normal: '128x128>' },
                   default_style: :mini
    validate :icon_is_an_image


  end

  def attachment_partial_name
    'paperclip'
  end
end
