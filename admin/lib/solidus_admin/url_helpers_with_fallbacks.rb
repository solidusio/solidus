# frozen_string_literal: true

module SolidusAdmin
  # SolidusAdmin's engine routes, with fallbacks to Spree::Backend's routes
  #
  # This module is temporary and it'll be removed once we don't need to fallback
  # to the old backend when a route is not present in Solidus Admin.
  #
  # @api private
  class UrlHelpersWithFallbacks
    def initialize(solidus_admin:, spree:)
      @solidus_admin = solidus_admin
      @spree = spree
    end

    def method_missing(method, ...)
      if @solidus_admin.respond_to?(method)
        @solidus_admin.public_send(method, ...)
      elsif @spree.respond_to?("admin_#{method}")
        @spree.public_send("admin_#{method}", ...)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @solidus_admin.respond_to?(method, include_private) ||
        @spree.respond_to?("admin_#{method}", include_private) ||
        super
    end
  end
end
