# frozen_string_literal: true

module Spree
  class Image < Asset
    include ::Spree::Config.image_attachment_module
  end
end

