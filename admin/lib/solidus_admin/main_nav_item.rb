# frozen_string_literal: true

module SolidusAdmin
  # Encapsulates the data for a main navigation item.
  class MainNavItem
    # @!attribute [r] key
    #  @return [String] a unique identifier for this item
    attr_reader :key

    # @!attribute [r] icon
    #  @return [String] icon from RemixIcon to use for this item
    attr_reader :icon

    # @!attribute [r] position
    #  @return [Integer] the position of this item relative to its parent
    attr_reader :position

    # @!attribute [r] route
    # @return [Symbol, Proc] the route to use for this item. When a symbol is
    #   given, it will be called on the solidus_admin url helpers. When a proc is
    #   given, it will be evaluated in a context that has access to the
    #   solidus url helpers.
    # @see #path
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

    # @param url_helpers [#solidus_admin, #spree] context object giving access
    #   to url helpers
    # @return [String] the path for this item
    def path(url_helpers)
      case @route
      when Symbol
        url_helpers.solidus_admin.public_send(@route)
      when Proc
        url_helpers.instance_exec(&@route)
      end
    end

    # Returns whether the item should be marked as current
    #
    # An item is considered the current one if its base path (that is, the path
    # without any query parameters) matches the given full path.
    #
    # @param url_helpers [#solidus_admin, #spree] context object giving access
    #  to url helpers
    # @param fullpath [String] the full path of the current request
    # @return [Boolean]
    def current?(url_helpers, fullpath)
      path(url_helpers) == fullpath.gsub(/\?.*$/, '')
    end

    # Returns whether the item should be marked as active
    #
    # An item is considered active when it is the current item or any of its
    # children is active.
    #
    # @param url_helpers [#solidus_admin, #spree] context object giving access
    #   to url helpers
    # @param fullpath [String] the full path of the current request
    # @return [Boolean]
    # @see #current?
    def active?(url_helpers, fullpath)
      current?(url_helpers, fullpath) ||
        children.any? { |child| child.active?(url_helpers, fullpath) }
    end
  end
end
