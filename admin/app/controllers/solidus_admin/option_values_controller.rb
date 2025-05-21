# frozen_string_literal: true

module SolidusAdmin
  class OptionValuesController < SolidusAdmin::ResourcesController

    private

    def resource_class = Spree::OptionValue
  end
end
