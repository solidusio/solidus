module Spree
  module TestingSupport
    module Preferences
      # Resets all preferences to default values, you can
      # pass a block to override the defaults with a block
      #
      # reset_solidus_preferences do |config|
      #   config.track_inventory_levels = false
      # end
      #
      def reset_solidus_preferences(&config_block)
        Solidus::Config.preference_store = Solidus::Config.default_preferences

        configure_solidus_preferences(&config_block) if block_given?
      end

      def configure_solidus_preferences
        config = Rails.application.config.solidus.preferences
        yield(config) if block_given?
      end

      def assert_preference_unset(preference)
        find("#preferences_#{preference}")['checked'].should be false
        Solidus::Config[preference].should be false
      end
    end
  end
end

