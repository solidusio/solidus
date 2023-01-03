# frozen_string_literal: true

module Solidus
  class ReleaseDrafter
    # Simple data structure wrapping what we need to save GH release drafts.
    #
    # @api private
    class Draft
      attr_reader :url, :content

      def self.empty
        new(url: nil, content: nil)
      end

      def initialize(url:, content:)
        @url = url
        @content = content&.encode(universal_newline: true)
      end

      def new?
        @url.nil?
      end

      def with(content:)
        self.class.new(content: content, url: @url)
      end
    end
  end
end

