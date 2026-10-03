# frozen_string_literal: true

module Spree
  # Adapts ActiveStorage interface to make it compliant with Solidus'
  # Paperclip-oriented attachment support.
  #
  # The first attachment the model declares is its main attachment: it is the
  # one returned by +attachment+ and used by +url+, +styles+, +default_style+
  # and +filename+. A model that has attributes with those names should use
  # {Spree::ActiveStorageAdapter::HasAttachments} instead.
  module ActiveStorageAdapter
    extend ActiveSupport::Concern
    include Spree::ActiveStorageAdapter::HasAttachments

    class_methods do
      def has_attachment(name, definition)
        super

        alias_method :attachment, name if name.to_sym == attachment_name && name.to_sym != :attachment
      end
    end

    def styles
      self.class.attachment_definition[:styles]
    end

    def default_style
      self.class.attachment_definition[:default_style]
    end

    def filename
      attachment.filename
    end

    def url(style = default_style)
      attachment.url(style)
    rescue ActiveStorage::FileNotFoundError
      "noimage/#{style}.png"
    end
  end
end
