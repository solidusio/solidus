# frozen_string_literal: true

require 'active_support/deprecation'

module Spree
  Deprecation = ActiveSupport::Deprecation.new('3.0', 'Solidus')
end
