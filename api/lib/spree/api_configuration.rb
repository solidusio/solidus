# frozen_string_literal: true

module Spree
  class ApiConfiguration < Preferences::Configuration
    preference :requires_authentication, :boolean, default: true
    preference :disable_api_routes, :boolean, default: false
  end
end
