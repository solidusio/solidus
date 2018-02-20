# frozen_string_literal: true

module Spree::Preferences
  module PreferableClassMethods
    DEFAULT_ADMIN_FORM_PREFERENCE_TYPES = %i(
      boolean
      decimal
      integer
      password
      string
      text
    )

    def defined_preferences
      []
    end

    def preference(name, type, options = {})
      options.assert_valid_keys(:default)
      default = options[:default]
      default = ->{ options[:default] } unless default.is_a?(Proc)

      # The defined preferences on a class are all those defined directly on
      # that class as well as those defined on ancestors.
      # We store these as a class instance variable on each class which has a
      # preference. super() collects preferences defined on ancestors.
      singleton_preferences = (@defined_singleton_preferences ||= [])
      singleton_preferences << name.to_sym

      define_singleton_method :defined_preferences do
        super() + singleton_preferences
      end

      # cache_key will be nil for new objects, then if we check if there
      # is a pending preference before going to default
      define_method preference_getter_method(name) do
        preferences.fetch(name) do
          default.call
        end
      end

      define_method preference_setter_method(name) do |value|
        value = convert_preference_value(value, type)
        preferences[name] = value

        # If this is an activerecord object, we need to inform
        # ActiveRecord::Dirty that this value has changed, since this is an
        # in-place update to the preferences hash.
        preferences_will_change! if respond_to?(:preferences_will_change!)
      end

      define_method preference_default_getter_method(name), &default

      define_method preference_type_getter_method(name) do
        type
      end
    end

    def preference_getter_method(name)
      "preferred_#{name}".to_sym
    end

    def preference_setter_method(name)
       "preferred_#{name}=".to_sym
    end

    def preference_default_getter_method(name)
      "preferred_#{name}_default".to_sym
    end

    def preference_type_getter_method(name)
      "preferred_#{name}_type".to_sym
    end

    # List of preference types allowed as form fields in the Solidus admin
    #
    # Overwrite this method in your class that includes +Spree::Preferable+
    # if you want to provide more fields. If you do so, you also need to provide
    # a preference field partial that lives in:
    #
    # +app/views/spree/admin/shared/preference_fields/+
    #
    # @return [Array]
    def allowed_admin_form_preference_types
      DEFAULT_ADMIN_FORM_PREFERENCE_TYPES
    end
  end
end
