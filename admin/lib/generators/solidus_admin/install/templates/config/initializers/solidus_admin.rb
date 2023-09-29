# frozen_string_literal: true

SolidusAdmin::Config.configure do |config|
  # Path to the logo used in the admin interface.
  #
  # It needs to be a path to an image file accessible by Sprockets.
  # config.logo_path = "my_own_logo.svg"

  # Add custom paths for TailwindCSS to scan for styles. By default, it already
  # includes the following paths:
  # - public/solidus_admin/*.html
  # - app/helpers/solidus_admin/**/*.rb
  # - app/assets/javascripts/solidus_admin/**/*.js
  # - app/views/solidus_admin/**/*.{erb,haml,html,slim}
  # - app/components/solidus_admin/**/*.{rb,erb,haml,html,slim,js}
  #
  # config.tailwind_content << Rails.root.join("app/my/custom/path/**.rb")

  # Append custom stylesheets to be compiled by TailwindCSS.
  # config.tailwind_stylesheets << Rails.root.join("app/my/custom/path/style.css")

  # Add custom folder paths to watch for changes to trigger a cache sweep forcing a
  # regeneration of the importmap.
  # config.importmap_cache_sweepers << Rails.root.join("app/javascript/my_admin_components")

  # Add custom paths to importmap files to be loaded.
  # config.importmap_paths << Rails.root.join("config/solidus_admin_importmap.rb")
  #
  # Configure the main navigation.
  # See SolidusAdmin::MainNavItem for more details.
  # config.menu_items << {
  #   key: :my_custom_link,
  #   route: :my_custom_link_path,
  #   icon: "solidus_admin/price-tag-3-line.svg",
  #   position: 80,
  #   children: [
  #     {
  #       key: :my_custom_child_link,
  #       route: :my_custom_child_link_path,
  #       position: 10
  #     }
  #   ]
  # }
end
