# frozen_string_literal: true

module Spree
  module Preferences
    module Persistable
      extend ActiveSupport::Concern

      included do
        include Spree::Preferences::Preferable

        if Rails.gem_version >= Gem::Version.new("7.1")
          serialize :preferences, type: Hash, coder: YAML
        else
          serialize :preferences, Hash, coder: YAML
        end

        after_initialize :initialize_preference_defaults
      end

      private

      def initialize_preference_defaults
        return unless has_attribute?(:preferences)

        merged = default_preferences.merge(preferences)
        self.preferences = merged unless merged == preferences
      end
    end
  end
end
