# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Theme
  extend ActiveSupport::Concern

  included do
    before_action :update_user_theme
  end

  private

  def update_user_theme
    requested_theme = params[:switch_to_theme].presence or return

    # Avoid interpolating user content into the session key
    system_theme = (params[:system_theme].presence == "dark") ? "dark" : "light"
    session_key = :"admin_#{system_theme}_theme"

    if theme_is_available?(requested_theme) && requested_theme.to_sym != session[session_key]
      session[session_key] = requested_theme

      flash[:notice] = t("spree.theme_changed")
      redirect_to params.except(:switch_to_theme, :system_theme).permit!.to_h.merge(account_menu_open: true)
    end
  end

  def theme_is_available?(theme)
    theme && SolidusAdmin::Config.themes.key?(theme.to_sym)
  end
end
