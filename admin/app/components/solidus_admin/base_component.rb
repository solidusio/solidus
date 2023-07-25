# frozen_string_literal: true

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ContainerHelper

    def icon_tag(name, **attrs)
      render component("ui/icon").new(name: name, **attrs)
    end

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
  end
end
