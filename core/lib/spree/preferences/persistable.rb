# frozen_string_literal: true

module Spree
  module Preferences
    module Persistable
      extend ActiveSupport::Concern

      included do
        include Spree::Preferences::Preferable
        serialize :preferences, Hash
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

