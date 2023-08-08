# frozen_string_literal: true

require 'spree/preferences/configuration'
require 'solidus_admin/configuration/main_nav'

module SolidusAdmin
  # Configuration for the admin interface.
  #
  # Ensure requiring this file after the Rails application has been created,
  # as some defaults depend on the application context.
  class Configuration < Spree::Preferences::Configuration
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
      SolidusAdmin::Engine.root.join("app/helpers/**/*.rb"),
      SolidusAdmin::Engine.root.join("app/assets/javascripts/**/*.js"),
      SolidusAdmin::Engine.root.join("app/views/**/*.erb"),
      SolidusAdmin::Engine.root.join("app/components/**/*.{rb,erb,js}"),
      SolidusAdmin::Engine.root.join("spec/components/previews/**/*.erb"),

      Rails.root.join("public/solidus_admin/*.html"),
      Rails.root.join("app/helpers/solidus_admin/**/*.rb"),
      Rails.root.join("app/assets/javascripts/solidus_admin/**/*.js"),
      Rails.root.join("app/views/solidus_admin/**/*.{erb,haml,html,slim}"),
      Rails.root.join("app/components/solidus_admin/**/*.{rb,erb,haml,html,slim,js}")
    ]

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
      SolidusAdmin::Engine.root.join("app", "assets", "javascripts"),
      SolidusAdmin::Engine.root.join("app", "javascript"),
      SolidusAdmin::Engine.root.join("app", "components"),
    ]

    # List of paths to importmap files to be loaded.
    #
    # @see https://github.com/rails/importmap-rails#composing-import-maps
    preference :importmap_paths, :array, default: [
      SolidusAdmin::Engine.root.join("config", "importmap.rb"),
    ]

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
    #  SolidusAdmin::Config.main_nav do |main_nav|
    #    main_nav.add(
    #      key: :my_custom_link,
    #      route: :products_path,
    #      icon: "solidus_admin/price-tag-3-line.svg",
    #      position: 80
    #    )
    # end
    #
    # @return [SolidusAdmin::Configuration::MainNav]
    # @yieldparam [SolidusAdmin::Configuration::MainNav] main_nav
    def main_nav
      (@main_nav ||= MainNav.new).tap do
        yield(_1) if block_given?
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
