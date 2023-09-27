# frozen_string_literal: true

require 'spree/core/versioned_value'
require 'spree/preferences/preferable'

module Spree::Preferences
  # This takes the preferrable methods and adds some
  # syntatic sugar to access the preferences
  #
  #   class App < Configuration
  #     preference :color, :string
  #   end
  #
  #   a = App.new
  #
  # Provides the following setters:
  #
  #   a.color = :blue
  #   a[:color] = :blue
  #   a.set color: :blue
  #   a.preferred_color = :blue
  #
  # and the following getters:
  #
  #   a.color
  #   a[:color]
  #   a.get :color
  #   a.preferred_color
  #
  class Configuration
    include Spree::Preferences::Preferable

    # @!attribute [r] loaded_defaults
    #   @return [String]
    #     Some configuration defaults can be added or changed when a new Solidus
    #     version is released. Setting this to an older Solidus version allows keeping
    #     backward compatibility until the application code is updated to the new
    #     defaults. Set via {#load_defaults}
    attr_reader :loaded_defaults

    # @api private
    attr_reader :load_defaults_called

    def initialize
      @loaded_defaults = Spree.solidus_version
      @load_defaults_called = false
    end

    # @param [String] Solidus version from which take defaults when preferences
    # are not overriden by the user.
    # @see #loaded_defaults
    def load_defaults(version)
      @loaded_defaults = version
      @load_defaults_called = true
      reset
    end

    def check_load_defaults_called(instance_constant_name = nil)
      return if load_defaults_called || !Spree::Core.has_install_generator_been_run?

      target_name = instance_constant_name || "#{self.class.name}.new"
      Spree.deprecator.warn <<~MSG
        It's recommended that you explicitly load the default configuration for
        your current Solidus version. You can do it by adding the following call
        to your Solidus initializer within the #{target_name} block:

          config.load_defaults('#{Spree.solidus_version}')

      MSG
    end

    # @yield [config] Yields this configuration object to a block
    def configure
      yield(self)
    end

    # @!attribute preference_store
    # Storage method for preferences.
    attr_writer :preference_store
    def preference_store
      @preference_store ||= default_preferences
    end

    # Replace the default legacy preference store, which stores preferences in
    # the spree_preferences table, with a plain in memory hash. This is faster
    # and less error prone.
    #
    # This will set all preferences to their default values.
    #
    # These won't be loaded from or persisted to the database, so any desired
    # changes must be made each time the application is started, such as in an
    # initializer.
    def use_static_preferences!
      @preference_store = default_preferences
    end

    # Replace the new static preference store with the legacy store which
    # fetches preferences from the DB.
    def use_legacy_db_preferences!
      @preference_store = ScopedStore.new(self.class.name.underscore)
    end

    alias_method :preferences, :preference_store

    # Reset all preferences to their default values.
    def reset
      set(default_preferences)
    end

    alias :[] :get_preference
    alias :[]= :set_preference

    alias :get :get_preference

    # @param preferences [Hash] a hash of preferences to set
    def set(preferences)
      preferences.each do |name, value|
        set_preference name, value
      end
    end

    def self.inherited(klass)
      klass.instance_variable_set(:@versioned_preferences, [])
      class << klass
        attr_reader :versioned_preferences
      end
    end

    # Adds a preference with different default depending on {#loaded_defaults}
    #
    # This method is a specialized version of {.preference} that generates a
    # different default value for different Solidus versions. For instance, in
    # the example, `foo`'s default was `true` until version 3.0.0.alpha, when it
    # became `false`:
    #
    # @example
    #   versioned_preference :foo, :boolean, initial_value: true, boundaries: { "3.0.0.alpha" => false }
    #
    # @see .preference
    # @see #loaded_defaults
    # @see Spree::Core::VersionedValue
    def self.versioned_preference(name, type, initial_value:, boundaries:, **options)
      @versioned_preferences << name
      preference(
        name,
        type,
        options.merge(
          default: by_version(initial_value, boundaries)
        )
      )
    end

    def self.preference(name, type, options = {})
      super
      alias_method name.to_s, "preferred_#{name}"
      alias_method "#{name}=", "preferred_#{name}="
    end

    def self.class_name_attribute(name, default:)
      ivar = :"@#{name}"

      define_method("#{name}=") do |class_name|
        # If this is a named class constant, we should store it as a string to
        # allow code reloading.
        class_name = class_name.name if class_name.is_a?(Class) && class_name.name

        instance_variable_set(ivar, class_name)
      end

      define_method(name) do
        class_name = instance_variable_get(ivar)
        class_name ||= default
        class_name = class_name.constantize if class_name.is_a?(String)
        class_name
      end
    end

    def self.by_version(*args)
      proc do |loaded_defaults|
        Spree::Core::VersionedValue.new(*args).call(loaded_defaults)
      end
    end
    private_class_method :by_version

    private

    def context_for_default
      [loaded_defaults]
    end
  end
end
