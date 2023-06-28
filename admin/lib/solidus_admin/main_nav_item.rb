# frozen_string_literal: true

module SolidusAdmin
  # Encapsulates the data for a main navigation item.
  class MainNavItem
    # @!attribute [r] key
    #  @return [String] a unique identifier for this item
    attr_reader :key

    # @!attribute [r] icon
    #  @return [String] asset path to an icon for this item
    attr_reader :icon

    # @!attribute [r] position
    #  @return [Integer] the position of this item relative to its parent
    attr_reader :position

    # @api private
    attr_reader :children, :top_level

    def initialize(key:, position:, icon: nil, children: [], top_level: true)
      @key = key
      @icon = icon
      @position = position
      @children = children
      @top_level = top_level
    end

    # @return [MainNavItem] adds a child to this item (returning a new instance)
    def with_child(key:, position:, icon: nil, children: [])
      self.class.new(
        key: self.key,
        icon: self.icon,
        position: self.position,
        top_level: top_level,
        children: self.children + [
          self.class.new(
            key: key,
            position: position,
            icon: icon,
            children: children,
            top_level: false
          )
        ]
      )
    end

    # @return [Boolean] whether this item has any children
    def children?
      @children.any?
    end
  end
end
