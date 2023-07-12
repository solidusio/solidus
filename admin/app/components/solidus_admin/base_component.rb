# frozen_string_literal: true

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ContainerHelper

    # Renders a remixincon svg.
    #
    # @param name [String] the name of the icon
    # @option attrs [String] :class the class to add to the svg
    # @return [String] the svg tag
    # @see https://remixicon.com/
    def icon_tag(name, **attrs)
      href = image_path("solidus_admin/remixicon.symbol.svg") + "#ri-#{name}"
      tag.svg(
        class: attrs[:class],
      ) do
        tag.use(
          "xlink:href": href
        )
      end
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
