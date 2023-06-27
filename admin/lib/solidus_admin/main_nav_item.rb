# frozen_string_literal: true

module SolidusAdmin
  # Encapsulates the data for a main nav item.
  class MainNavItem
    attr_reader :key, :icon, :position

    # @param key [String]
    # @param icon [String]
    # @param position [Integer]
    def initialize(key:, icon:, position:)
      @key = key
      @icon = icon
      @position = position
    end
  end
end
