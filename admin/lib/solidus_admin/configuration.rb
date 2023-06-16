# frozen_string_literal: true

require 'spree/preferences/configuration'

module SolidusAdmin
  # Configuration for the admin interface.
  #
  # Ensure requiring this file after the Rails application has been created,
  # as some defaults depend on the application context.
  class Configuration < Spree::Preferences::Configuration
    # Path to the logo used in the admin interface.
    #
    # It needs to be a path to an image file accessible by Sprockets.
    preference :logo_path, :string, default: "solidus_admin/solidus_logo.svg"

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
      SolidusAdmin::Engine.root.join("public/*.html"),
      SolidusAdmin::Engine.root.join("app/helpers/**/*.rb"),
      SolidusAdmin::Engine.root.join("app/assets/javascripts/**/*.js"),
      SolidusAdmin::Engine.root.join("app/views/**/*.{erb,haml,html,slim}"),
      SolidusAdmin::Engine.root.join("app/components/**/*.rb"),
      Rails.root.join("public/solidus_admin/*.html"),
      Rails.root.join("app/helpers/solidus_admin/**/*.rb"),
      Rails.root.join("app/assets/javascripts/solidus_admin/**/*.js"),
      Rails.root.join("app/views/solidus_admin/**/*.{erb,haml,html,slim}"),
      Rails.root.join("app/components/solidus_admin/**/*.rb")
    ]

    # List of Tailwind CSS files to be combined into the final stylesheet.
    #
    # You can modify this list to include your own files:
    #
    #   SolidusAdmin::Config.tailwind_stylesheets << Rails.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css")
    #
    # Recompile with `bin/rails solidus_admin:tailwindcss:build` after changing this list.
    preference :tailwind_stylesheets, :array, default: []

    preference :importmap_cache_sweepers, :array, default: [
      SolidusAdmin::Engine.root.join("app", "assets", "javascripts"),
      SolidusAdmin::Engine.root.join("app", "javascript"),
      SolidusAdmin::Engine.root.join("app", "components"),
    ]

    preference :importmap_paths, :array, default: [
      SolidusAdmin::Engine.root.join("config", "importmap.rb"),
    ]
  end
end

SolidusAdmin::Config = SolidusAdmin::Configuration.new
