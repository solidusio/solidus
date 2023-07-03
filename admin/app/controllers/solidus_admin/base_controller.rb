# frozen_string_literal: true

require 'geared_pagination'

module SolidusAdmin
  class BaseController < ApplicationController
    include ActiveStorage::SetCurrent
    include ::SolidusAdmin::Auth
    include Spree::Core::ControllerHelpers::Store

    include ::GearedPagination::Controller

    layout 'solidus_admin/application'
    helper 'solidus_admin/container'
    helper 'solidus_admin/layout'
  end
end
