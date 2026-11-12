# frozen_string_literal: true

module SolidusAdmin
  class StatesController < SolidusAdmin::ResourcesController
    private

    def resource_class
      Spree::State
    end

    def resources_sorting_options
      {name: :asc}
    end

    def blueprint
      SolidusAdmin::StateBlueprint
    end

    def blueprint_view
      view = params[:view]&.to_sym
      blueprint.view?(view) ? view : :default
    end

    def per_page
      100
    end
  end
end
