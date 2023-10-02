# frozen_string_literal: true

module Spree
  class BackendConfiguration < Preferences::Configuration
    # An item which should be drawn in the admin menu
    class MenuItem
      attr_reader :icon, :label, :partial, :children, :condition, :data_hook, :match_path

      def sections # rubocop:disable Style/TrivialAccessors
        @sections
      end
      deprecate sections: :label, deprecator: Spree.deprecator

      attr_accessor :position # rubocop:disable Layout/EmptyLinesAroundAttributeAccessor
      deprecate position: nil, deprecator: Spree.deprecator
      deprecate "position=": nil, deprecator: Spree.deprecator

      # @param icon [String] The icon to draw for this menu item
      # @param condition [Proc] A proc which returns true if this menu item
      #   should be drawn. If nil, it will be replaced with a proc which always
      #   returns true.
      # @param label [Symbol] The translation key for a label to use for this
      #   menu item.
      # @param children [Array<Spree::BackendConfiguration::MenuItem>] An array
      # @param url [String|Symbol] A url where this link should send the user to or a Symbol representing a route name
      # @param match_path [String, Regexp, callable] (nil) If the {url} to determine the active tab is ambigous
      #   you can pass a String, Regexp or callable to identify this menu item. The callable
      #   accepts a request object and returns a Boolean value.
      def initialize(
        *args,
        icon: nil,
        condition: nil,
        label: nil,
        partial: nil,
        children: [],
        url: nil,
        position: nil,
        data_hook: nil,
        match_path: nil
      )
        if args.length == 2
          sections, icon = args
          label ||= sections.first.to_s
          Spree.deprecator.warn "Passing sections to #{self.class.name} is deprecated. Please pass a label instead."
          Spree.deprecator.warn "Passing icon to #{self.class.name} is deprecated. Please use the keyword argument instead."
        elsif args.any?
          raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0..2)"
        end

        if partial.present? && children.blank?
          # We only show the deprecation if there are no children, because if there are children,
          # then the menu item is already future-proofed.
          Spree.deprecator.warn "Passing a partial to #{self.class.name} is deprecated. Please use the children keyword argument instead."
        end

        @condition = condition || -> { true }
        @sections = sections || []
        @icon = icon
        @label = label
        @partial = partial
        @children = children
        @url = url
        @data_hook = data_hook
        @match_path = match_path

        self.position = position if position # Use the setter to deprecate
      end

      def render_in?(view_context)
        view_context.instance_exec(&@condition) ||
          children.any? { |child| child.render_in?(view_context) }
      end

      def render_partial?
        return false if partial.blank?

        children.blank? || Spree::Backend::Config.prefer_menu_item_partials
      end

      def match_path?(request)
        matches =
          if match_path.is_a? Regexp
            request.fullpath =~ match_path
          elsif match_path.respond_to?(:call)
            match_path.call(request)
          elsif match_path
            request.fullpath.starts_with?("#{spree.admin_path}#{match_path}")
          end
        matches ||= request.fullpath.to_s.starts_with?(url.to_s) if url.present?
        matches ||= @sections.include?(request.controller_class.controller_name.to_sym) if @sections.present?

        matches
      end

      def url
        url = @url.call if @url.respond_to?(:call)
        url ||= spree.public_send(@url) if @url.is_a?(Symbol) && spree.respond_to?(@url)
        url ||= spree.send("admin_#{@label}_path") if @url.nil? && @label && spree.respond_to?("admin_#{@label}_path")
        url ||= @url.to_s
        url
      end

      private

      def spree
        Spree::Core::Engine.routes.url_helpers
      end
    end
  end
end
