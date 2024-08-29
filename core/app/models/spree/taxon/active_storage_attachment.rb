# frozen_string_literal: true

module Spree::Taxon::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  included do
    has_attachment :icon,
      styles: Spree::Config.taxon_image_styles,
      default_style: Spree::Config.taxon_image_style_default
    validate :icon_is_an_image
  end
end
