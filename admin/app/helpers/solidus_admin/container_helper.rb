# frozen_string_literal: true

require "solidus_admin/container"

module SolidusAdmin
  module ContainerHelper
    def container
      SolidusAdmin::Container
    end

    def component(name)
      container.resolve("#{name}_component")
    end
  end
end
