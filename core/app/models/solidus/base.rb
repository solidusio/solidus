class Solidus::Base < ActiveRecord::Base
  include Solidus::Preferences::Preferable
  serialize :preferences, Hash

  include Solidus::RansackableAttributes

  after_initialize do
    if has_attribute?(:preferences)
      self.preferences = default_preferences.merge(preferences)
    end
  end

  if Kaminari.config.page_method_name != :page
    def self.page num
      send Kaminari.config.page_method_name, num
    end
  end

  self.abstract_class = true
end
