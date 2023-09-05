# frozen_string_literal: true

module SolidusAdmin
  module ComponentsHelper
    def component(name)
      SolidusAdmin::Config.components[name]
    end
  end
end
