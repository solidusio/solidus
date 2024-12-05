# frozen_string_literal: true

module SolidusAdmin
  module ComponentsHelper
    def component(name)
      SolidusAdmin::Config.components[name]
    end

    def search_filter_params
      request.params.slice(:q, :page)
    end
  end
end
