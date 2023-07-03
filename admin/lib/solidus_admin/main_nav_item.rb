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

    # @!attribute [r] route
    # @return [Symbol, Proc] the route to use for this item. When a symbol
    #  is given, it will be called on the url helpers. When a proc is given,
    #  it will be called with the url helpers as the first argument.
    attr_reader :route

    # @api private
    attr_reader :children, :top_level

    def initialize(key:, position:, route:, icon: nil, children: [], top_level: true)
      @key = key
      @icon = icon
      @position = position
      @children = children
      @top_level = top_level
      @route = route
    end

    # @return [MainNavItem] adds a child to this item (returning a new instance)
    def with_child(key:, route:, position:, icon: nil, children: [])
      self.class.new(
        key: self.key,
        route: self.route,
        icon: self.icon,
        position: self.position,
        top_level: top_level,
        children: self.children + [
          self.class.new(
            key: key,
            route: route,
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

    # @param url_helpers [Module] the url helpers to use for generating the path
    # @return [String] the path for this item
    def path(url_helpers)
      case @route
      when Symbol
        url_helpers.public_send(@route)
      when Proc
        @route.call(url_helpers)
      end
    end

    # Returns whether the item should be marked as active
    #
    # An item is considered active if its base path (that is, the path without
    # any query parameters) matches the given full path.
    #
    # @param url_helpers [Module] the url helpers to use for generating the path
    # @param fullpath [String] the full path of the current request
    # @return [Boolean]
    def active?(url_helpers, fullpath)
      (path(url_helpers) == fullpath.gsub(/\?.*$/, '')) ||
        children.any? { |child| child.active?(url_helpers, fullpath) }
    end
  end
end
