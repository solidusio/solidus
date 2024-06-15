# frozen_string_literal: true

require "solidus_core"
require "solidus_support"
require "turbo-rails"
require "importmap-rails"
require "stimulus-rails"
require "ransack-enum"

begin
  require "solidus_backend"
rescue LoadError
  # Solidus backend is not available
end

module SolidusFriendlyPromotions
  def self.table_name_prefix
    "friendly_"
  end

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new
end

require "solidus_friendly_promotions/configuration"
require "solidus_friendly_promotions/version"
require "solidus_friendly_promotions/engine"
