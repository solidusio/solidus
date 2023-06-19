# frozen_string_literal: true

module SolidusAdmin
  class RolesController < SolidusAdmin::BaseController
    def index
      @roles = Spree::Role.all
    end
  end
end
