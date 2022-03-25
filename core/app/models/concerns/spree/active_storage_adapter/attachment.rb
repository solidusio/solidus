# frozen_string_literal: true

require 'mini_magick'

module Spree
  module ActiveStorageAdapter
    # Decorares AtiveStorage attachment to add methods exptected by Solidus'
    # Paperclip-oriented attachment support.
    class Attachment
      delegate_missing_to :@attachment

      def initialize(attachment, styles: {})
        @attachment = attachment
        @styles = normalize_styles(styles)
      end

      def exists?
        attached?
      end

      def filename
        blob&.filename.to_s
      end

      def url(style = nil)
        variant(style)&.url
      end

      def variant(style = nil)
        size = style_to_size(style)
        @attachment.variant(
          resize_to_limit: size,
          saver: {
            strip: true
          }
        ).processed
      end

      def height
        metadata[:height]
      end

      def width
        metadata[:width]
      end

      def destroy
        return false unless attached?

        purge
        true
      end

      private

      def metadata
        analyze unless analyzed?

        @attachment.metadata
      end

      def normalize_styles(styles)
        styles.transform_values { |v| v.split('x').map(&:to_i) }
      end

      def style_to_size(style)
        @styles.fetch(style&.to_sym) { [width, height] }
      end
    end
  end
end
