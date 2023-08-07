# frozen_string_literal: true

module Spree
  class BackendConfiguration < Preferences::Configuration
    # An item which should be drawn in the admin menu
    class MenuItem
      attr_reader :icon, :label, :partial, :condition, :match_path

      def sections # rubocop:disable Style/TrivialAccessors
        @sections
      end
      deprecate sections: :label, deprecator: Spree::Deprecation

      attr_accessor :position

      # @param icon [String] The icon to draw for this menu item
      # @param condition [Proc] A proc which returns true if this menu item
      #   should be drawn. If nil, it will be replaced with a proc which always
      #   returns true.
      # @param label [Symbol] The translation key for a label to use for this
      #   menu item.
      # @param partial [String] A partial to draw within this menu item for use
      #   in declaring a submenu
      # @param url [String|Symbol] A url where this link should send the user to or a Symbol representing a route name
      # @param position [Integer] The position in which the menu item should render
      #   nil will cause the item to render last
      # @param match_path [String, Regexp, callable] (nil) If the {url} to determine the active tab is ambigous
      #   you can pass a String, Regexp or callable to identify this menu item. The callable
      #   accepts a request object and returns a Boolean value.
      def initialize(
        *args,
        icon: nil,
        condition: nil,
        label: nil,
        partial: nil,
        url: nil,
        position: nil,
        match_path: nil
      )
        if args.length == 2
          sections, icon = args
          label ||= sections.first.to_s
          Spree::Deprecation.warn "Passing sections to #{self.class.name} is deprecated. Please pass a label instead."
          Spree::Deprecation.warn "Passing icon to #{self.class.name} is deprecated. Please use the keyword argument instead."
        elsif args.any?
          raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0..2)"
        end

        @condition = condition || -> { true }
        @sections = sections
        @icon = icon
        @label = label
        @partial = partial
        @url = url
        @position = position
        @match_path = match_path
      end

      def url
        if @url.respond_to?(:call)
          @url.call
        elsif @url.is_a?(Symbol)
          spree.public_send(@url)
        elsif @url.nil?
          spree.send("admin_#{@label}_path")
        else
          @url
        end
      end

      private

      def spree
        Spree::Core::Engine.routes.url_helpers
      end
    end
  end
end
