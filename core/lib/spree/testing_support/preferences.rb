# frozen_string_literal: true

module Spree
  module TestingSupport
    module Preferences
      # Resets all preferences to default values, you can
      # pass a block to override the defaults with a block
      #
      # reset_spree_preferences do |config|
      #   config.track_inventory_levels = false
      # end
      #
      def reset_spree_preferences(&config_block)
        Spree::Config.instance_variables.each { |iv| Spree::Config.remove_instance_variable(iv) }
        Spree::Config.preference_store = Spree::Config.default_preferences

        if defined?(Railties)
          Rails.application.config.spree = Spree::Config.environment
        end

        configure_spree_preferences(&config_block) if block_given?
      end

      def configure_spree_preferences
        yield(Spree::Config) if block_given?
      end

      def assert_preference_unset(preference)
        find("#preferences_#{preference}")['checked'].should be false
        Spree::Config[preference].should be false
      end
    end
  end
end
