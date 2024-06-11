# frozen_string_literal: true

module Spree
  module Preferences
    module Persistable
      extend ActiveSupport::Concern

      included do
        include Spree::Preferences::Preferable

        if method(:serialize).parameters.include?([:key, :type]) # Rails 7.1+
          serialize :preferences, type: Hash, coder: YAML
        else
          serialize :preferences, Hash, coder: YAML
        end

        after_initialize :initialize_preference_defaults
      end

      private

      def initialize_preference_defaults
        if has_attribute?(:preferences)
          self.preferences = default_preferences.merge(preferences)
        end
      end
    end
  end
end
