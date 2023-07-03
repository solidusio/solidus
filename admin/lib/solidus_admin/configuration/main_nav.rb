# frozen_string_literal: true

require "solidus_admin/container"
require "solidus_admin/main_nav_item"

module SolidusAdmin
  class Configuration < Spree::Preferences::Configuration
    # Configuration for the main navigation menu.
    class MainNav
      NAMESPACE = "main_nav"
      private_constant :NAMESPACE

      # @api private
      def initialize(container: SolidusAdmin::Container)
        @container = container
      end

      # Adds a new item to the main navigation menu
      #
      # @return [SolidusAdmin::MainNavItem]
      # @see SolidusAdmin::MainNavItem for the available parameters. `children:`
      # is to be forwarded to the `#with_child` method.
      def add(key:, children: [], **kwargs)
        item = item(children: children, **kwargs.merge(key: key))

        register(key, item) &&
          resolve(key)
      end

      private

      def register(key, item)
        @container.register(
          container_key(key),
          item
        )
      end

      def resolve(key)
        @container.resolve(
          container_key(key)
        )
      end

      def container_key(key)
        "#{NAMESPACE}#{@container.config.namespace_separator}#{key}"
      end

      def item(children:, **kwargs)
        children.reduce(MainNavItem.new(**kwargs)) do |item, child|
          item.with_child(**child)
        end
      end
    end
  end
end
