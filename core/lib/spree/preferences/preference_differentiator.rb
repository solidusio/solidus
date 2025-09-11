# frozen_string_literal: true

module Spree
  module Preferences
    class PreferenceDifferentiator
      attr_reader :config_class

      def initialize(config_class)
        @config_class = config_class
      end

      def call(from:, to:)
        preferences_from = config_class.new.load_defaults(from)
        preferences_to = config_class.new.load_defaults(to)
        config_class.versioned_preferences.reduce({}) do |changes, pref_key|
          value_from = preferences_from[pref_key]
          value_to = preferences_to[pref_key]
          if value_from == value_to
            changes
          else
            changes.merge(
              pref_key => {from: value_from, to: value_to}
            )
          end
        end
      end
    end
  end
end
