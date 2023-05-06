# frozen_string_literal: true

class SolidusAdmin::BaseController < Spree::BaseController
  layout 'solidus_admin'

  private

  def current_admin_user
    Spree::User.admin.first
  end
end
