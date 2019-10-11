# frozen_string_literal: true

module Solidus
  class Image < Asset
    include ::Solidus::Config.image_attachment_module

    def mini_url
      Solidus::Deprecation.warn(
        'Solidus::Image#mini_url is DEPRECATED. Use Solidus::Image#url(:mini) instead.'
      )
      url(:mini)
    end
  end
end
