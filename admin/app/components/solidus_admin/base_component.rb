# frozen_string_literal: true

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include SolidusAdmin::ContainerHelper

    def stimulus_id
      @stimulus_id ||= self.class.module_parent.to_s.underscore.dasherize.gsub(%r{/}, '--')
    end

    def spree
      @spree ||= Spree::Core::Engine.routes.url_helpers
    end

    def with_components(overrides)
      @local_component_overrides ||= {}.with_indifferent_access
      @local_component_overrides.merge!(overrides)

      self
    end

    def component(name)
      return super unless @local_component_overrides&.key?(name)

      @local_component_overrides[name]
    end
  end
end
