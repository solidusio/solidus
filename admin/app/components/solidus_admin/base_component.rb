# frozen_string_literal: true

require "solidus_admin/url_helpers_with_fallbacks"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ContainerHelper

    def self.stimulus_id
      @stimulus_id ||= name.underscore
        .sub(/^solidus_admin\/(.*)\/component$/, '\1')
        .gsub("/", "--")
        .tr("_", "-")
    end

    delegate :stimulus_id, to: :class

    def spree
      @spree ||= Spree::Core::Engine.routes.url_helpers
    end

    def solidus_admin
      @solidus_admin ||= SolidusAdmin::Engine.routes.url_helpers
    end

    def solidus_admin_with_fallbacks
      @solidus_admin_with_fallbacks ||= UrlHelpersWithFallbacks.new(
        spree: spree,
        solidus_admin: solidus_admin
      )
    end
  end
end
