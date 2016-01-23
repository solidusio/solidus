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
      @preference_store ||= preference_db_store
    end

    # @!attribute preference_db_store
    # Storage method for database preferences. Default is {ScopedStore}
    attr_writer :preference_db_store
    def preference_db_store
      @preference_db_store ||= ScopedStore.new(self.class.name.underscore)
    end

    # Replace the default legacy preference store, which stores preferences in
    # the spree_preferences table, with a plain in memory hash. This is faster
    # and less error prone.
    # This will persist to database, but only reload when initialize.
    # So you can't update from rails console and see change take effect
    # in your rails server immediately.
    def use_static_preferences!
      static_preferences = {}
      default_preferences.each do |key, value|
        static_preferences[key] = db_preferences.fetch(key) {} || value
      end
      @preference_store = static_preferences
    end

    alias_method :preferences, :preference_store
    alias_method :db_preferences, :preference_db_store

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

    def self.preference name, type, options={}
      super
      alias_method "#{name}", "preferred_#{name}"
      alias_method "#{name}=", "preferred_#{name}="
    end
  end
end
