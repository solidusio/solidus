# frozen_string_literal: true

require "solidus_core"
require "solidus_api"
require "solidus_backend"
require "solidus_admin"
require "solidus_support"

module SolidusLegacyPromotions
  VERSION = Spree.solidus_version
end

require "solidus_legacy_promotions/engine"
