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
      # @param prefs_or_conf_class [Class, Hash] the class we want to stub
      #   preferences for or the preferences hash (see prefs param). If this
      #   param is an Hash, preferences will be stubbed on Spree::Config.
      # @param prefs [Hash, nil] names and values to be stubbed
      #
      # @example Stubs `currency` and `track_inventory_levels` on `Spree::Config`:
      #   stub_spree_preferences(currency: 'EUR', track_inventory_levels: false)
      #   expect(Spree::Config.currency).to eql 'EUR'
      #
      # @example Stubs `locale` preference on `Spree::Backend::Config`:
      #   stub_spree_preferences(Spree::Backend::Config, locale: 'fr'),
      #   expect(Spree::Backend::Config.locale).to eql 'fr'
      #
      # @see https://github.com/solidusio/solidus/issues/3219
      #   Solidus #3219 for more details and motivations.
      def stub_spree_preferences(prefs_or_conf_class, prefs = nil)
        if prefs_or_conf_class.is_a?(Hash)
          preference_store_class = Spree::Config
          preferences = prefs_or_conf_class
        else
          preference_store_class = prefs_or_conf_class
          preferences = prefs
        end

        preferences.each do |name, value|
          if preference_store_class.method(:[]).owner >= preference_store_class.class
            allow(preference_store_class).to receive(:[]).and_call_original
          end
          allow(preference_store_class).to receive(:[]).with(name) { value }
          allow(preference_store_class).to receive(name) { value }
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
      def with_unfrozen_spree_preference_store(preference_store_class: Spree::Config)
        frozen_store = preference_store_class.preference_store
        preference_store_class.preference_store = preference_store_class[:unfrozen_preference_store].dup
        yield
      ensure
        preference_store_class.preference_store = frozen_store
      end

      # This class method allows to freeze preferences for a specific
      # configuration store class. It also stores the current state into
      # a new preference of that store, so it can be reused when needed
      # (eg. with_unfrozen_spree_preference_store)
      #
      # It is meant to be used by extensions as well, for example if one
      # extension has its own Spree::ExtensionName::Config class, we can
      # freeze it and be sure we always stub values on it during tests.
      #
      # @param preference_store_class [Class] the configuration class we want
      #   to freeze.
      def self.freeze_preferences(preference_store_class)
        config_class = preference_store_class.class
        config_class.preference :unfrozen_preference_store, :hash
        preference_store_class.unfrozen_preference_store = preference_store_class.preference_store.dup
        preference_store_class.preference_store.freeze
      end
    end
  end
end

RSpec.configure do |config|
  config.before :suite do
    %w[
      Spree::Config
      Spree::Frontend::Config
      Spree::Backend::Config
      Spree::Api::Config
    ].each do |configuration_class|
      if Object.const_defined?(configuration_class)
        Spree::TestingSupport::Preferences.freeze_preferences(configuration_class.constantize)
      end
    end
  end
end
