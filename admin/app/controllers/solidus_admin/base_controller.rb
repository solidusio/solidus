# frozen_string_literal: true

require 'geared_pagination'

module SolidusAdmin
  class BaseController < ApplicationController
    include ActiveStorage::SetCurrent
    include Spree::Core::ControllerHelpers::Store
    include GearedPagination::Controller

    include SolidusAdmin::ControllerHelpers::Authentication
    include SolidusAdmin::ControllerHelpers::Locale
    include SolidusAdmin::ComponentsHelper
    include SolidusAdmin::AuthenticationAdapters::Backend if defined?(Spree::Backend)

    layout 'solidus_admin/application'
    helper 'solidus_admin/components'
    helper 'solidus_admin/layout'
  end
end
