# frozen_string_literal: true

module Spree
  class Image < Asset
    include ::Spree::Config.image_attachment_module

    def self.attachment_preloads
      Spree::Config.image_attachment_module.attachment_preloads
    end
  end
end
