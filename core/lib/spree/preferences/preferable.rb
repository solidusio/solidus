# frozen_string_literal: true

require 'spree/preferences/preferable_class_methods'
require 'active_support/concern'
require 'active_support/core_ext/hash/keys'

module Spree
  module Preferences
    # Preferable allows defining preference accessor methods.
    #
    # A class including Preferable must implement #preferences which should return
    # an object responding to .fetch(key), []=(key, val), and .delete(key).
    #
    # The generated writer method performs typecasting before assignment into the
    # preferences object.
    #
    # Examples:
    #
    #   # Spree::Base includes Preferable and defines preferences as a serialized
    #   # column.
    #   class Settings < Spree::Base
    #     preference :color,       :string,  default: 'red'
    #     preference :temperature, :integer, default: 21
    #   end
    #
    #   s = Settings.new
    #   s.preferred_color # => 'red'
    #   s.preferred_temperature # => 21
    #
    #   s.preferred_color = 'blue'
    #   s.preferred_color # => 'blue'
    #
    #   # Typecasting is performed on assignment
    #   s.preferred_temperature = '24'
    #   s.preferred_color # => 24
    #
    #   # Modifications have been made to the .preferences hash
    #   s.preferences #=> {color: 'blue', temperature: 24}
    #
    #   # Save the changes. All handled by activerecord
    #   s.save!
    #
    # Each preference gets rendered as a form field in Solidus backend.
    #
    # As not all supported preference types are representable as a form field, only
    # some of them get rendered per default. Arrays and Hashes for instance are
    # supported preference field types, but do not represent well as a form field.
    #
    # Overwrite +allowed_admin_form_preference_types+ in your class if you want to
    # provide more fields. If you do so, you also need to provide a preference field
    # partial that lives in:
    #
    # +app/views/spree/admin/shared/preference_fields/+
    #
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

      # @return [Hash{Symbol => Object}] Default for all preferences defined on this class
      def default_preferences
        Hash[
          defined_preferences.map do |preference|
            [preference, preference_default(preference)]
          end
        ]
      end

      # Preference names representable as form fields in Solidus backend
      #
      # Not all preferences are representable as a form field.
      #
      # Arrays and Hashes for instance are supported preference field types,
      # but do not represent well as a form field.
      #
      # As these kind of preferences are mostly developer facing
      # and not admin facing we should not render them.
      #
      # Overwrite +allowed_admin_form_preference_types+ in your class that
      # includes +Spree::Preferable+ if you want to provide more fields.
      # If you do so, you also need to provide a preference field partial
      # that lives in:
      #
      # +app/views/spree/admin/shared/preference_fields/+
      #
      # @return [Array]
      def admin_form_preference_names
        defined_preferences.keep_if do |type|
          preference_type(type).in? self.class.allowed_admin_form_preference_types
        end
      end

      private

      def convert_preference_value(value, type)
        return nil if value.nil?
        case type
        when :string, :text
          value.to_s
        when :password
          value.to_s
        when :decimal
          begin
            value.to_s.to_d
          rescue ArgumentError
            BigDecimal(0)
          end
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
    end
  end
end
