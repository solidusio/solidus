# frozen_string_literal: true

module Spree
  module ActiveStorageAttachment
    extend ActiveSupport::Concern

    # @private
    def self.attachment_variant(attachment, style:, default_style:, styles:)
      return unless attachment && attachment.attachment

      if style.nil? || style == default_style
        attachment_variant = attachment
      else
        attachment_variant = attachment.variant(
          resize: styles[style.to_sym],
          strip: true,
          'auto-orient': true,
          colorspace: 'sRGB',
        ).processed
      end

      attachment_variant
    end

    class_methods do
      def redefine_attachment_writer_with_legacy_io_support(name)
        define_method :"#{name}=" do |attachable|
          attachment = public_send(name)

          case attachable
          when ActiveStorage::Blob, ActionDispatch::Http::UploadedFile,
               Rack::Test::UploadedFile, Hash, String
            attachment.attach(attachable)
          when ActiveStorage::Attached
            attachment.attach(attachable.blob)
          else # assume it's an IO
            if attachable.respond_to?(:to_path)
              filename = attachable.to_path
            else
              filename = SecureRandom.uuid
            end
            attachable.rewind

            attachment.attach(
              io: attachable,
              filename: filename
            )
          end
        end
      end

      def validate_attachment_to_be_an_image(name)
        method_name = :"attached_#{name}_is_an_image"

        define_method method_name do
          attachment = public_send(name)
          next if attachment.nil? || attachment.attachment.nil?

          errors.add name, 'is not an image' unless attachment.attachment.image?
        end

        validate method_name
      end
    end
  end
end
