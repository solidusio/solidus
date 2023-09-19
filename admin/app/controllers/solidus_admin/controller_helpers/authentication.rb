# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_solidus_admin_user!

    helper_method :current_solidus_admin_user
    helper_method :solidus_admin_logout_path
    helper_method :solidus_admin_logout_method
  end

  private

  def authenticate_solidus_admin_user!
    send SolidusAdmin::Config.authentication_method if SolidusAdmin::Config.authentication_method
  end

  def current_solidus_admin_user
    send SolidusAdmin::Config.current_user_method if SolidusAdmin::Config.current_user_method
  end

  def solidus_admin_logout_path
    SolidusAdmin::Config.logout_link_path
  end

  def solidus_admin_logout_method
    SolidusAdmin::Config.logout_link_method
  end
end
