# frozen_string_literal: true

require "solidus_core"
require "solidus_api"
require "solidus_backend"
require "solidus_support"

# If `solidus_admin` is available, it needs to load before
# our engine is initialized, so that our load paths can
# be initialized.
begin
  require 'solidus_admin'
rescue LoadError
  # Solidus Admin is not available
end
module SolidusLegacyPromotions
  VERSION = Spree.solidus_version
end

require "solidus_legacy_promotions/engine"
