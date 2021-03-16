# frozen_string_literal: true

class Spree::Base < ActiveRecord::Base
  include Spree::Preferences::Preferable
  include Spree::Core::Permalinks
  include Spree::RansackableAttributes

  def preferences
    value = read_attribute(:preferences)
    if !value.is_a?(Hash)
      Spree::Deprecation.warn <<~WARN
        #{self.class.name} has a `preferences` column, but does not explicitly (de)serialize this column.
        In order to make #{self.class.name} work with future versions of Solidus (and Rails), please add the
        following to lines to your class:
        ```
        class #{self.class.name}
          serialize :preferences, Hash
          after_initialize :initialize_preference_defaults
          ...
        end
        ```
      WARN
      self.class.serialize :preferences, Hash
      self.class.after_initialize :initialize_preference_defaults

      ActiveRecord::Type::Serialized.new(
        ActiveRecord::Type::Text.new,
        ActiveRecord::Coders::YAMLColumn.new(:preferences, Hash)
      ).deserialize(value)
    else
      value
    end
  end

  def initialize_preference_defaults
    if has_attribute?(:preferences)
      self.preferences = default_preferences.merge(preferences)
    end
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
