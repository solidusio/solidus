# frozen_string_literal: true

module Solidus
  # Bumps a version in a file
  #
  # @api private
  module Bumper
    def self.call(from:, to:, path:)
      File.read(path)
        .then { |content| content.gsub(from, to) }
        .then { |content| File.write(path, content) }
    end
  end
end
