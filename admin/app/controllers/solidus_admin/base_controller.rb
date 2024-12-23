# frozen_string_literal: true

require 'geared_pagination'

module SolidusAdmin
  class BaseController < ApplicationController
    include ActiveStorage::SetCurrent
    include Spree::Core::ControllerHelpers::Store
    include GearedPagination::Controller

    include SolidusAdmin::ControllerHelpers::Authentication
    include SolidusAdmin::ControllerHelpers::Authorization
    include SolidusAdmin::ControllerHelpers::Locale
    include SolidusAdmin::ControllerHelpers::Theme
    include SolidusAdmin::ComponentsHelper
    include SolidusAdmin::AuthenticationAdapters::Backend if defined?(Spree::Backend)

    layout :set_layout

    helper 'solidus_admin/components'
    helper 'solidus_admin/layout'

    helper_method :search_filter_params

    private

    def search_filter_params
      request.params.slice(:q, :page)
    end

    def set_layout
      if turbo_frame_request?
        false
      else
        'solidus_admin/application'
      end
    end
  end
end
