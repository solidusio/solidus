# frozen_string_literal: true

require "solidus_core"
require "solidus_support"

module SolidusLegacyPromotions
  VERSION = Spree.solidus_version
end

require "spree/core/environment/calculators_extension"
require "solidus_legacy_promotions/engine"
