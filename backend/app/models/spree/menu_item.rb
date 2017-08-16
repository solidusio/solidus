# An item which should be drawn in the admin menu
module Spree
  class MenuItem
    attr_reader :icon, :label, :partial, :condition, :sections, :url

    # @param sections [Array<Symbol>] The sections which are contained within
    #   this admin menu section.
    # @param icon [String] The icon to draw for this menu item
    # @param condition [Proc] A proc which returns true if this menu item
    #   should be drawn. If nil, it will be replaced with a proc which always
    #   returns true.
    # @param label [Symbol] The translation key for a label to use for this
    #   menu item.
    # @param partial [String] A partial to draw within this menu item for use
    #   in declaring a submenu
    # @param url [String] A url where this link should send the user to
    def initialize(
      sections,
      icon,
      condition: nil,
      label: nil,
      partial: nil,
      url: nil
    )

      @condition = condition || -> { true }
      @sections = sections
      @icon = icon
      @label = label || sections.first
      @partial = partial
      @url = url
    end
  end
end
