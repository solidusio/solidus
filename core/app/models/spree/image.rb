# frozen_string_literal: true

module Spree
  class Image < Asset
    include ::Spree::Config.image_attachment_module

    def mini_url
      Spree::Deprecation.warn(
        'Spree::Image#mini_url is DEPRECATED. Use Spree::Image#url(:mini) instead.'
      )
      url(:mini)
    end
  end
end
