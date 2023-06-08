# frozen_string_literal: true

require "solidus_admin/system/import"

module SolidusAdmin
  # BaseComponent is the base class for all components in Solidus Admin.
  class BaseComponent < ViewComponent::Base
    include ViewComponent::InlineTemplate
    include SolidusAdmin::ContainerHelper

    def identifier
      @identifier ||= module_parent.to_s.underscore.dasherize.gsub(%r{/}, '--')
    end
  end
end
