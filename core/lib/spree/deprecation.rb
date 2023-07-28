# frozen_string_literal: true

require 'spree/core'

module Spree
  Deprecation = Spree.deprecator

  Spree.deprecator.warn "Spree::Deprecation is deprecated. Please use Spree.deprecator instead.", caller(2)
end
