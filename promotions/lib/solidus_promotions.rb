# frozen_string_literal: true

require "solidus_core"
require "solidus_support"
require "turbo-rails"
require "importmap-rails"
require "stimulus-rails"
require "ransack-enum"

# We carry controllers and views for both the traditional backend
# and the new Solidus Admin interface, but we want to continue to function
# if either of them are not present. If they are present,
# however, they need to load before us.
begin
  require "solidus_backend"
rescue LoadError
  # Solidus backend is not available
end

begin
  require "solidus_admin"
rescue LoadError
  # Solidus Admin is not available
end

module SolidusPromotions
  def self.table_name_prefix
    "solidus_promotions_"
  end

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new
end

require "solidus_promotions/configuration"
require "solidus_promotions/version"
require "solidus_promotions/engine"
