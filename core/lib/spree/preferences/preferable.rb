# frozen_string_literal: true

require "spree/preferences/preferable_class_methods"
require "active_support/concern"
require "active_support/core_ext/hash/keys"

module Spree
  module Preferences
    # Preference types explicitly supported by the +Preferable+ module.
    TYPES = %i[
      array
      boolean
      decimal
      encrypted_string
      hash
      integer
      password
      string
      text
    ]

    # A subset of preference types that correspond to Solidus admin-provided
    # form fields. These types should be be renderable in any user-facing form
    # for any preference-enabled model.
    FORM_FIELD_TYPES = TYPES - %i[array hash]

    # +Preferable+ allows the defining of preference accessor methods. This
    # allows you to provide user-facing forms with customized fields without
    # adding additional attributes to your database tables.
    #
    # A class including +Preferable+ must implement a +#preferences+
    # method. That method must return an object that responds to:
    #
    #  - +.fetch(key)+,
    #  - +[]=(key, val)+,
    #  - and +.delete(key)+.
    #
    # It may also define a +#context_for_default+ method. That method should
    # return an array with the arguments to be provided to a proc used as the
    # +default:+ keyword for a preference.
    #
    # The generated writer method performs typecasting before assignment into
    # the preferences object.
    #
    # @example
    #   class MySettings < Spree::Base
    #     include Spree::Preferences::Preferable
    #
    #     preference :color,       :string,  default: 'red'
    #     preference :temperature, :integer, default: 21
    #   end
    #
    #   s = MySettings.new
    #   s.preferred_color # => 'red'
    #   s.preferred_temperature # => 21
    #
    #   s.preferred_color = 'blue'
    #   s.preferred_color # => 'blue'
    #
    #   # Typecasting is performed on assignment.
    #   s.preferred_temperature = '24'
    #   s.preferred_color # => 24
    #
    #   # Modifications have been made to the preferences hash.
    #   s.preferences #=> {color: 'blue', temperature: 24}
    #   s.save!
    module Preferable
      extend ActiveSupport::Concern

      included do
        extend Spree::Preferences::PreferableClassMethods
      end

      # Get a preference
      # @param name [#to_sym] name of preference
      # @return [Object] The value of preference +name+
      def get_preference(name)
        has_preference! name
        send self.class.preference_getter_method(name)
      end

      # Set a preference
      # @param name [#to_sym] name of preference
      # @param value [Object] new value for preference +name+
      def set_preference(name, value)
        has_preference! name
        send self.class.preference_setter_method(name), value
      end

      # @param name [#to_sym] name of preference
      # @return [Symbol] The type of preference +name+
      def preference_type(name)
        has_preference! name
        send self.class.preference_type_getter_method(name)
      end

      # @param name [#to_sym] name of preference
      # @return [Object] The default for preference +name+
      def preference_default(name)
        has_preference! name
        send self.class.preference_default_getter_method(name)
      end

      # Raises an exception if the +name+ preference is not defined on this class
      # @param name [#to_sym] name of preference
      def has_preference!(name)
        raise NoMethodError.new "#{name} preference not defined" unless has_preference? name
      end

      # @param name [#to_sym] name of preference
      # @return [Boolean] if preference exists on this class
      def has_preference?(name)
        defined_preferences.include?(name.to_sym)
      end

      # @return [Array<Symbol>] All preferences defined on this class
      def defined_preferences
        self.class.defined_preferences
      end

      # The default values for all preferences defined on the current class.
      #
      # @return [Hash{Symbol => Object}] default preference values
      def default_preferences
        defined_preferences.map do |preference|
          [preference, preference_default(preference)]
        end.to_h
      end

      # Preference types representable as form fields in Solidus backend. Not
      # all preference types are representable as admin form fields. See the
      # method documentation for the class method
      #
      #   +Spree::Preferences::Preferable.allowed_admin_form_preference_types+
      #
      # for more information.
      #
      # @return [Array]
      def admin_form_preference_names
        defined_preferences.keep_if do |type|
          preference_type(type).in? self.class.allowed_admin_form_preference_types
        end
      end

      private

      def convert_preference_value(value, type, preference_encryptor = nil)
        return nil if value.nil?
        case type
        when :string, :text
          value.to_s
        when :encrypted_string
          preference_encryptor.encrypt(value.to_s)
        when :password
          value.to_s
        when :decimal
          value.to_s.to_d
        when :integer
          value.to_i
        when :boolean
          if !value ||
              value.to_s =~ /\A(f|false|0|^)\Z/i ||
              (value.respond_to?(:empty?) && value.empty?)
            false
          else
            true
          end
        when :array
          raise TypeError, "Array expected got #{value.inspect}" unless value.is_a?(Array)
          value
        when :hash
          raise TypeError, "Hash expected got #{value.inspect}" unless value.is_a?(Hash)
          value
        else
          value
        end
      end

      def context_for_default
        [].freeze
      end
    end
  end
end
