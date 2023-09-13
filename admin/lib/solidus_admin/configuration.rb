# frozen_string_literal: true

require 'spree/preferences/configuration'

module SolidusAdmin
  # Configuration for the admin interface.
  #
  # Ensure requiring this file after the Rails application has been created,
  # as some defaults depend on the application context.
  class Configuration < Spree::Preferences::Configuration
    ComponentNotFoundError = Class.new(NameError)
    ENGINE_ROOT = File.expand_path("#{__dir__}/../..")

    # Path to the logo used in the admin interface.
    #
    # It needs to be a path to an image file accessible by Sprockets.
    # The default value is the Solidus logo that lives in the solidus_core gem.
    preference :logo_path, :string, default: "logo/solidus.svg"

    # The list of paths were Tailwind CSS classes are used.
    #
    # You can modify this list to include your own paths:
    #
    #    SolidusAdmin::Config.tailwind_content << Rails.root.join("app/my/custom/path")
    #
    # Recompile with `bin/rails solidus_admin:tailwindcss:build` after changing this list.
    #
    # @see https://tailwindcss.com/docs/configuration#content
    preference :tailwind_content, :array, default: [
      "#{ENGINE_ROOT}/app/helpers/**/*.rb",
      "#{ENGINE_ROOT}/app/assets/javascripts/**/*.js",
      "#{ENGINE_ROOT}/app/views/**/*.erb",
      "#{ENGINE_ROOT}/app/components/**/*.{rb,erb,js}",
      "#{ENGINE_ROOT}/spec/components/previews/**/*.{erb,rb}",

      Rails.root&.join("public/solidus_admin/*.html"),
      Rails.root&.join("app/helpers/solidus_admin/**/*.rb"),
      Rails.root&.join("app/assets/javascripts/solidus_admin/**/*.js"),
      Rails.root&.join("app/views/solidus_admin/**/*.{erb,haml,html,slim}"),
      Rails.root&.join("app/components/solidus_admin/**/*.{rb,erb,haml,html,slim,js}")
    ].compact

    # List of Tailwind CSS files to be combined into the final stylesheet.
    #
    # You can modify this list to include your own files:
    #
    #   SolidusAdmin::Config.tailwind_stylesheets << Rails.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css")
    #
    # Recompile with `bin/rails solidus_admin:tailwindcss:build` after changing this list.
    preference :tailwind_stylesheets, :array, default: []

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

    # @!attribute [rw] orders_per_page
    #   @return [Integer] The number of orders to display per page in the admin interface.
    #                     This preference determines the pagination limit for the order listing.
    #                     The default value is fetched from the Spree core configuration and currently set to 15.
    preference :orders_per_page, :integer, default: Spree::Config[:orders_per_page]

    # @!attribute [rw] order_search_key
    #   The key that specifies the attributes for searching orders within the admin interface.
    #   This preference controls which attributes of an order are used in search queries.
    #   By default, it is set to
    #   'number_shipments_number_or_bill_address_name_or_email_order_promotions_promotion_code_value_cont',
    #   enabling a search across order number, shipment number, billing address name, email, and promotion code value.
    #   @return [String] The search key used to determine order attributes for search.
    preference :order_search_key, :string, default: :number_or_shipments_number_or_bill_address_name_or_email_or_order_promotions_promotion_code_value_cont

    # @!attribute [rw] products_per_page
    #   @return [Integer] The number of products to display per page in the admin interface.
    #                     This preference determines the pagination limit for the product listing.
    #                     The default value is fetched from the Spree core configuration and currently set to 10.
    preference :products_per_page, :integer, default: Spree::Config[:admin_products_per_page]

    # @!attribute [rw] product_search_key
    #   @return [String] The key to use when searching for products in the admin interface.
    #                    This preference determines the product attribute to use for search.
    #                    By default, it is set to 'name_or_variants_including_master_sku_cont',
    #                    meaning it will search by product name or product variants sku.
    preference :product_search_key, :string, default: :name_or_variants_including_master_sku_cont

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
            },
            {
              key: "taxons",
              route: -> { spree.admin_taxons_path },
              position: 40
            }
          ]
        },

        {
          key: "promotions",
          route: -> { spree.admin_promotions_path },
          icon: "megaphone-line",
          position: 30,
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

    def components
      @components ||= Hash.new do |_h, k|
        "solidus_admin/#{k}/component".classify.constantize
      rescue NameError
        prefix = "#{ENGINE_ROOT}/app/components/solidus_admin/"
        suffix = "/component.rb"
        dictionary = Dir["#{prefix}**#{suffix}"].map { _1.delete_prefix(prefix).delete_suffix(suffix) }
        corrections = DidYouMean::SpellChecker.new(dictionary: dictionary).correct(k.to_s)

        raise ComponentNotFoundError, "Unknown component #{k}#{DidYouMean.formatter.message_for(corrections)}"
      end
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
  end
end

SolidusAdmin::Config = SolidusAdmin::Configuration.new
