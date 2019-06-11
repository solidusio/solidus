# frozen_string_literal: true

require 'spree/deprecation'

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
      # @deprecated
      def reset_spree_preferences(&config_block)
        Spree::Config.instance_variables.each { |iv| Spree::Config.remove_instance_variable(iv) }
        Spree::Config.preference_store = Spree::Config.default_preferences

        if defined?(Railties)
          Rails.application.config.spree = Spree::Config.environment
        end

        configure_spree_preferences(&config_block) if block_given?
      end

      deprecate :reset_spree_preferences, deprecator: Spree::Deprecation

      def configure_spree_preferences
        yield(Spree::Config) if block_given?
      end

      def assert_preference_unset(preference)
        find("#preferences_#{preference}")['checked'].should be false
        Spree::Config[preference].should be false
      end

      # This is the preferred way for changing temporarily Spree preferences during
      # tests via stubs, without changing the actual values stored in Spree::Config.
      #
      # By using stubs no global preference change will leak outside the lifecycle
      # of each spec example, avoiding possible unpredictable side effects.
      #
      # This method  may be used for stubbing one or more different preferences
      # at the same time.
      #
      # @param [Hash] preferences names and values to be stubbed
      #
      # @example Stubs `currency` and `track_inventory_levels` preferences
      #   stub_spree_preferences(currency: 'EUR', track_inventory_levels: false)
      #   expect(Spree::Config.currency).to eql 'EUR'
      #
      # @see https://github.com/solidusio/solidus/issues/3219
      #   Solidus #3219 for more details and motivations.
      def stub_spree_preferences(preferences)
        preferences.each do |name, value|
          if Spree::Config.method(:[]).owner >= Spree::Config.class
            allow(Spree::Config).to receive(:[]).and_call_original
          end
          allow(Spree::Config).to receive(:[]).with(name) { value }
          allow(Spree::Config).to receive(name) { value }
        end
      end

      # This method allows to temporarily switch to an unfrozen Spree::Config preference
      # store with all proper preferences values set.
      #
      # It should be used sparingly, only when `stub_spree_preferences` would not work.
      #
      # @example Temporarily switch to an unfrozen store and change some preferences:
      #   with_unfrozen_spree_preference_store do
      #     Spree::Config.currency = 'EUR'
      #     Spree::Config.track_inventory_levels = false
      #
      #     expect(Spree::Config.currency).to eql 'EUR'
      #   end
      # @see Spree::TestingSupport::Preferences#stub_spree_preferences
      def with_unfrozen_spree_preference_store
        frozen_store = Spree::Config.preference_store
        Spree::Config.preference_store = Spree::Config[:unfrozen_preference_store].dup
        yield
      ensure
        Spree::Config.preference_store = frozen_store
      end
    end
  end
end

RSpec.configure do |config|
  config.before :suite do
    # keep a copy of the original unfrozen preference_store for later use:
    Spree::AppConfiguration.preference :unfrozen_preference_store, :hash
    Spree::Config.unfrozen_preference_store = Spree::Config.preference_store.dup
    Spree::Config.preference_store.freeze
  end
end
