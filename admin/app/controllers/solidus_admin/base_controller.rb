# frozen_string_literal: true

module SolidusAdmin
  class BaseController < Spree::BaseController
    layout 'solidus_admin/application'
    helper 'solidus_admin/container'
  end
end
