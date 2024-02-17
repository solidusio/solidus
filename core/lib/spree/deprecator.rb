# frozen_string_literal: true

require 'active_support/deprecation'

module Spree
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('5.0', 'Solidus')
  end
end
