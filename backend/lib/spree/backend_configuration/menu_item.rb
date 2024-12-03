# frozen_string_literal: true

module Spree
  class BackendConfiguration < Preferences::Configuration
    # An item which should be drawn in the admin menu
    class MenuItem
      attr_reader :icon, :label, :partial, :condition, :sections, :match_path

      attr_accessor :position

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
      # @param position [Integer] The position in which the menu item should render
      #   nil will cause the item to render last
      # @param match_path [String, Regexp, callable] (nil) If the {url} to determine the active tab is ambigous
      #   you can pass a String, Regexp or callable to identify this menu item. The callable
      #   accepts a request object and returns a Boolean value.
      def initialize(
        sections,
        icon,
        condition: nil,
        label: nil,
        partial: nil,
        url: nil,
        position: nil,
        match_path: nil
      )
        @condition = condition || -> { true }
        @sections = sections
        @icon = icon
        @label = label || sections.first
        @partial = partial
        @url = url
        @position = position
        @match_path = match_path
      end

      def url
        if @url.respond_to?(:call)
          @url.call
        else
          @url
        end
      end
    end
  end
end
