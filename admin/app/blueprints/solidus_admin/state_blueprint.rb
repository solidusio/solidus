# frozen_string_literal: true

module SolidusAdmin
  class StateBlueprint < Blueprinter::Base
    identifier :id

    field :name

    view :state_with_country do
      field :state_with_country, name: :name
    end
  end
end
