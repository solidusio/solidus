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

    # @yield [config] Yields this configuration object to a block
    def configure
      yield(self)
    end

    # @!attribute preference_store
    # Storage method for preferences. Default is {ScopedStore}
    attr_writer :preference_store
    def preference_store
      @preference_store ||= ScopedStore.new(self.class.name.underscore)
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

    def self.preference(name, type, options = {})
      super
      alias_method name.to_s, "preferred_#{name}"
      alias_method "#{name}=", "preferred_#{name}="
    end
  end
end
