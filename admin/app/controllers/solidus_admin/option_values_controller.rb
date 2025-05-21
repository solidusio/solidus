# frozen_string_literal: true

module SolidusAdmin
  class OptionValuesController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    private

    def resource_class = Spree::OptionValue
  end
end
