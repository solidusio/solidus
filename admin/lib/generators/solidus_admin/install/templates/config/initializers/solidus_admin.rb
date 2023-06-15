# frozen_string_literal: true

SolidusAdmin::Config.configure do |config|
  # Path to the logo used in the admin interface.
  #
  # It needs to be a path to an image file accessible by Sprockets.
  # config.logo_path = "my_own_logo.svg"

  # Add custom paths for TailwindCSS to scan for styles. By default, it already
  # includes the following paths:
  #
  # - public/solidus_admin/*.html
  # - app/helpers/solidus_admin/**/*.rb
  # - app/assets/javascripts/solidus_admin/**/*.js
  # - app/views/solidus_admin/**/*.{erb,haml,html,slim}
  # - app/components/solidus_admin/**/*.rb
  # config.tailwind_content << Rails.root.join("app/my/custom/path/**.rb")

  # Append custom stylesheets to be compiled by TailwindCSS.
  # config.tailwind_stylesheets << Rails.root.join("app/my/custom/path/style.css")
end
