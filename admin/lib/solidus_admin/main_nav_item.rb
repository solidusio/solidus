# frozen_string_literal: true

module SolidusAdmin
  # Encapsulates the data for a main nav item.
  class MainNavItem
    attr_reader :title, :position

    # @param title [String]
    # @param position [Integer]
    def initialize(title:, position:)
      @title = title
      @position = position
    end
  end
end
