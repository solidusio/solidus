# frozen_string_literal: true

module SolidusAdmin
  module ContainerHelper
    def component(name)
      SolidusAdmin::Config.components[name]
    end
  end
end
