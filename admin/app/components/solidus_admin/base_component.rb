# frozen_string_literal: true

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include ViewComponent::InlineTemplate
    include SolidusAdmin::ContainerHelper

    def stimulus_id
      @stimulus_id ||= self.class.module_parent.to_s.underscore.dasherize.gsub(%r{/}, '--')
    end

    def spree
      @spree ||= Spree::Core::Engine.routes.url_helpers
    end
  end
end
