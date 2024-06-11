# frozen_string_literal: true

module Spree
  module Admin
    class ThemeController < Spree::Admin::BaseController
      skip_before_action :authorize_admin, only: [:set]

      def set
        requested_theme = params[:switch_to_theme].presence

        # Avoid interpolating user content into the session key
        system_theme = params[:system_theme].presence == "dark" ? "dark" : "light"
        session_key = :"admin_#{system_theme}_theme"

        if theme_is_available?(requested_theme)
          session[session_key] = requested_theme
          redirect_back_or_to spree.admin_url, notice: t('spree.theme_changed')
        else
          redirect_back_or_to spree.admin_url, error: t('spree.error')
        end
      end

      private

      def theme_is_available?(theme)
        theme && Spree::Backend::Config.themes.key?(theme.to_sym)
      end
    end
  end
end
