# frozen_string_literal: true

require 'spree/preferences/configuration'
require 'solidus_admin/component_registry'

module SolidusAdmin
  # Configuration for the admin interface.
  #
  # Ensure requiring this file after the Rails application has been created,
  # as some defaults depend on the application context.
  class Configuration < Spree::Preferences::Configuration
    ENGINE_ROOT = File.expand_path("#{__dir__}/../..")

    # Path to the logo used in the admin interface.
    #
    # It needs to be a path to an image file accessible by Sprockets.
    # The default value is the Solidus logo that lives in the solidus_core gem.
    preference :logo_path, :string, default: "logo/solidus.svg"

    # List of paths to watch for changes to trigger a cache sweep forcing a regeneration of the importmap.
    #
    # @see https://github.com/rails/importmap-rails#sweeping-the-cache-in-development-and-test
    preference :importmap_cache_sweepers, :array, default: [
      "#{ENGINE_ROOT}/app/assets/javascripts",
      "#{ENGINE_ROOT}/app/javascript",
      "#{ENGINE_ROOT}/app/components",
    ]

    # List of paths to importmap files to be loaded.
    #
    # @see https://github.com/rails/importmap-rails#composing-import-maps
    preference :importmap_paths, :array, default: [
      "#{ENGINE_ROOT}/config/importmap.rb",
    ]

    # @!attribute [rw] low_stock_value
    #   @return [Integer] The low stock value determines the threshold at which products are considered low in stock.
    #                     Products with a count_on_hand less than or equal to this value will be considered low in stock.
    #                     Default: 10
    preference :low_stock_value, :integer, default: 10

    # @!attribute [rw] enable_alpha_features?
    #   @return [Boolean] Determines whether alpha features are enabled or disabled in the application.
    #                     Setting this to `true` enables access to alpha stage features that might still be in testing or development.
    #                     Use with caution, as these features may not be fully stable or complete.
    #                     Default: false
    preference :enable_alpha_features, :boolean, default: true

    alias enable_alpha_features? enable_alpha_features

    preference :storefront_product_path_proc, :proc, default: ->(_version) {
      ->(product) { "/products/#{product.slug}" }
    }

    def storefront_product_path(product)
      storefront_product_path_proc.call(product)
    end

    # Gives access to the main navigation configuration
    #
    # @example
    #  SolidusAdmin::Config.menu_items << {
    #    key: :my_custom_link,
    #    route: :products_path,
    #    icon: "solidus_admin/price-tag-3-line.svg",
    #    position: 80
    #  }
    #
    # @api public
    # @return [Array<Hash>]
    def menu_items
      @menu_items ||= [
        {
          key: "orders",
          route: -> { spree.admin_orders_path },
          icon: "inbox-line",
          position: 10
        },
        {
          key: "products",
          route: :products_path,
          icon: "price-tag-3-line",
          position: 20,
          children: [
            {
              key: "products",
              route: -> { solidus_admin.products_path },
              match_path: -> { _1.start_with?("/admin/products/") },
              position: 0
            },
            {
              key: "option_types",
              route: -> { spree.admin_option_types_path },
              position: 10
            },
            {
              key: "property_types",
              route: -> { spree.admin_properties_path },
              position: 20
            },
            {
              key: "taxonomies",
              route: -> { spree.admin_taxonomies_path },
              position: 30
            }
          ]
        },

        {
          key: "stock",
          route: -> { spree.admin_stock_items_path },
          icon: "stack-line",
          position: 40
        },

        {
          key: "users",
          route: -> { spree.admin_users_path },
          icon: "user-line",
          position: 50
        },

        {
          key: "settings",
          route: -> { spree.admin_stores_path },
          icon: "settings-line",
          position: 60,
        }
      ]
    end

    def import_menu_items_from_backend!
      menu_item_to_hash = ->(item, index) do
        route =
          if item.url.is_a?(Symbol)
            -> { solidus_admin.public_send(item.url) }
          elsif item.url.is_a?(String)
            -> { item.url }
          elsif item.url.is_a?(Proc)
            item.url
          elsif item.url.nil?
            -> { spree.public_send(:"admin_#{item.label}_path") }
          else
            raise ArgumentError, "Unknown url type #{item.url.class}"
          end

        match_path =
          case item.match_path
          when Regexp then -> { _1 =~ item.match_path }
          when Proc then item.match_path
          when String then -> { _1.start_with?("/admin#{item.match_path}") }
          when nil then -> { _1.start_with?(route.call) }
          else raise ArgumentError, "Unknown match_path type #{item.match_path.class}"
          end

        icon =
          case item.icon
          when /^ri-/
            item.icon.delete_prefix("ri-")
          when String
            'record-circle-line' # fallback on a generic icon
          end

        {
          position: index,
          key: item.label,
          icon:,
          route:,
          children: item.children.map.with_index(&menu_item_to_hash),
          match_path:,
        }
      end

      @menu_items = Spree::Backend::Config.menu_items.map.with_index(&menu_item_to_hash)
    end

    def components
      @components ||= ComponentRegistry.new
    end

    # The method used to authenticate the user in the admin interface, it's expected to redirect the user to the login method
    # in case the authentication fails.
    preference :authentication_method, :string, default: :authenticate_solidus_backend_user!

    # The method used to retrieve the current user in the admin interface.
    preference :current_user_method, :string, default: :spree_current_user

    # The path used to logout the user in the admin interface.
    preference :logout_link_path, :string, default: '/admin/logout'

    # The HTTP method used to logout the user in the admin interface.
    preference :logout_link_method, :string, default: :delete

    # @!attribute [rw] themes
    #   @return [Hash] A hash containing the themes that are available for the admin panel
    preference :themes, :hash, default: {
      solidus: 'solidus_admin/application',
      solidus_dark: 'solidus_admin/dark',
      solidus_dimmed: 'solidus_admin/dimmed',
    }

    # @!attribute [rw] theme
    #   @return [String] Default admin theme name
    preference :theme, :string, default: 'solidus'

    # @!attribute [rw] dark_theme
    #   @return [String] Default admin theme name
    preference :dark_theme, :string, default: 'solidus_dark'

    def theme_path(user_theme)
      themes.fetch(user_theme&.to_sym, themes[theme.to_sym])
    end
  end
end

SolidusAdmin::Config = SolidusAdmin::Configuration.new
