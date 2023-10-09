# frozen_string_literal: true

require "solidus_core"
require "solidus_backend"
require "solidus_support"
require "turbo-rails"
require "importmap-rails"
require "stimulus-rails"
require "solidus_friendly_promotions/configuration"
require "solidus_friendly_promotions/version"
require "solidus_friendly_promotions/engine"

module SolidusFriendlyPromotions
  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new
end
