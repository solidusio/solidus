# frozen_string_literal: true

require "solidus_core"
require "solidus_api"
require "solidus_support"

# We carry controllers and views for both the traditional backend
# and the new Solidus Admin interface, but we want to continue to function
# if either of them are not present. If they are present,
# however, they need to load before us.
begin
  require 'solidus_admin'
rescue LoadError
  # Solidus Admin is not available
end

begin
  require "solidus_backend"
rescue LoadError
  # Solidus backend is not available
end

module SolidusLegacyPromotions
  VERSION = Spree.solidus_version
end

require "solidus_legacy_promotions/configuration"
require "solidus_legacy_promotions/engine"
