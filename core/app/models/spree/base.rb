# frozen_string_literal: true

class Spree::Base < ActiveRecord::Base
  include Spree::Preferences::Preferable
  include Spree::Core::Permalinks
  serialize :preferences, Hash

  include Spree::RansackableAttributes

  def initialize_preference_defaults
    if has_attribute?(:preferences)
      self.preferences = default_preferences.merge(preferences)
    end
  end

  # Only run preference initialization on models which requires it. Improves
  # performance of record initialization slightly.
  def self.preference(*args)
    # after_initialize can be called multiple times with the same symbol, it
    # will only be called once on initialization.
    after_initialize :initialize_preference_defaults
    super
  end

  if Kaminari.config.page_method_name != :page
    def self.page(num)
      Spree::Deprecation.warn \
        "Redefining Spree::Base.page for a different kaminari page name is better done inside " \
        "your own app. This will be removed from future versions of solidus."

      send Kaminari.config.page_method_name, num
    end
  end

  self.abstract_class = true

  # Provides a scope that should be included any time products
  # are fetched with the intention of displaying to the user.
  #
  # Allows individual stores to include any active record scopes or joins
  # when products are displayed.
  def self.display_includes
    where(nil)
  end
end
