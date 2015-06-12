# This takes the preferrable methods and adds some
# syntatic sugar to access the preferences
#
# class App < Configuration
#   preference :color, :string
# end
#
# a = App.new
#
# setters:
# a.color = :blue
# a[:color] = :blue
# a.set :color = :blue
# a.preferred_color = :blue
#
# getters:
# a.color
# a[:color]
# a.get :color
# a.preferred_color
#
#
module Spree::Preferences
  class Configuration
    include Spree::Preferences::Preferable

    def configure
      yield(self) if block_given?
    end

    attr_writer :preference_store
    def preference_store
      @preference_store ||= ScopedStore.new(self.class.name.underscore)
    end

    def use_static_preferences!
      @preference_store = default_preferences
    end

    alias_method :preferences, :preference_store

    def reset
      set(default_preferences)
    end

    alias :[] :get_preference
    alias :[]= :set_preference

    alias :get :get_preference

    def set(options)
      options.each do |name, value|
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
