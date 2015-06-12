# Configure Solidus Preferences

Spree.config do |config|
  # Without this preferences are loaded and persisted to the database. This
  # changes them to be stored in memory.
  # This will be the default in a future version.
  config.use_static_preferences!

  # Core:

  # Default currency for new sites
  config.currency = "USD"

  # from address for transactional emails
  config.mails_from = "store@example.com"

  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # When true, product caches are only invalidated when they come in or out of
  # stock. Default is to invalidate cache on any inventory changes.
  # config.binary_inventory_cache = true


  # Frontend:

  # Custom logo for the frontend
  # config.logo = "logo/spree_50.png"

  # Template to use when rendering layout
  # config.layout = "spree/layouts/spree_application"


  # Admin:

  # Custom logo for the admin
  # config.admin_interface_logo = "logo/spree_50.png"
end

Spree.user_class = <%= (options[:user_class].blank? ? "Spree::LegacyUser" : options[:user_class]).inspect %>
