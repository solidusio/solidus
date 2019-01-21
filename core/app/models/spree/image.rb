# frozen_string_literal: true

module Spree
  class Image < Asset
    if ::Spree::Config.image_attachment_module.blank?
      Spree::Deprecation.warn <<-MESSAGE.strip_heredoc + "\n\n"
        Using Paperclip as image_attachment_module for Solidus.

        Please configure Spree::Config.image_attachment_module in your store
        initializer.

        To use the Paperclip adapter
          Spree.config do |config|
            config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
          end
      MESSAGE
      ::Spree::Config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
    end

    include ::Spree::Config.image_attachment_module.to_s.constantize

    def mini_url
      Spree::Deprecation.warn(
        'Spree::Image#mini_url is DEPRECATED. Use Spree::Image#url(:mini) instead.'
      )
      url(:mini, false)
    end
  end
end
