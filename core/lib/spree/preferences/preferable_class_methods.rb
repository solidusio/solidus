# frozen_string_literal: true

require "spree/encryptor"

module Spree::Preferences
  module PreferableClassMethods
    class NoEncryptionKeyError < StandardError; end

    VALID_OPTIONS = [:default, :encryption_key]

    def defined_preferences = []

    # Generates a new preference for the current class. Every defined
    # preference provides a handful of accessor methods.
    #
    # Note that all preferable-enabled models inherit preferences (and
    # preference methods) from their superclasses.
    #
    # @param name [String] the name of the preference to be defined
    # @param type [Spree::Preferences::TYPES] the type of the
    #   preference to be defined
    # @param options [Hash] options for the new preference (see
    #   +VALID_OPTIONS+)
    # @return [void] defines the preference and its accessor methods
    def preference(name, type, options = {})
      options.assert_valid_keys(*VALID_OPTIONS)

      if type == :encrypted_string
        preference_encryptor = preference_encryptor(options)
        options[:default] = preference_encryptor.encrypt(options[:default])
      end

      default = begin
        given = options[:default]
        given.is_a?(Proc) ? given : proc { given }
      end

      singleton_preferences = (@defined_singleton_preferences ||= [])
      singleton_preferences << name.to_sym

      define_singleton_method :defined_preferences do
        super() + singleton_preferences
      end

      define_method preference_getter_method(name) do
        value = preferences.fetch(name) { instance_exec(*context_for_default, &default) }
        value = preference_encryptor.decrypt(value) if preference_encryptor.present?
        value
      end

      define_method preference_setter_method(name) do |value|
        value = convert_preference_value(value, type, preference_encryptor)
        preferences[name] = value

        # If this is an Active Record object, +ActiveRecord::Dirty+ should
        # notify whenever a preference value would change on persist.
        preferences_will_change! if respond_to?(:preferences_will_change!)
      end

      define_method preference_default_getter_method(name) do
        instance_exec(*context_for_default, &default)
      end

      define_method preference_type_getter_method(name) do
        type
      end
    end

    # Preference types allowed as form fields in the Solidus admin.
    #
    # Overwrite this method in classes that include
    # +Spree::Preferences::Preferable+ if you want to provide custom fields.
    #
    # If records are configurable via the Solidus admin, you must also add
    # corresponding view code to your application or extension for each field.
    #
    # In +solidus_backend+, place a view partial at:
    #
    #   +app/views/spree/admin/shared/preference_fields/<your_preference_type>.<partial_extension>+
    #
    # In +solidus_admin+, place view component files in the directory:
    #
    #   +app/components/solidus_admin/preference_fields/<your_preference_type>/+
    #
    # @return [Array]
    def allowed_admin_form_preference_types = Spree::Preferences::FORM_FIELD_TYPES

    def permitted_preference_attributes
      new.admin_form_preference_names.map { |name| :"preferred_#{name}" }
    end

    def preference_getter_method(name) = :"preferred_#{name}"

    def preference_setter_method(name) = :"preferred_#{name}="

    def preference_default_getter_method(name) = :"preferred_#{name}_default"

    def preference_type_getter_method(name) = :"preferred_#{name}_type"

    def preference_encryptor(options)
      key = options[:encryption_key] ||
        ENV["SOLIDUS_PREFERENCES_MASTER_KEY"] ||
        Rails.application.credentials.secret_key_base

      if key.blank?
        raise NoEncryptionKeyError,
          "must provide an encryption key for encrypted string preferences"
      end

      Spree::Encryptor.new(key)
    end
  end
end
