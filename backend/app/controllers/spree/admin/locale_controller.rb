# frozen_string_literal: true

module Spree
  module Admin
    class LocaleController < Spree::Admin::BaseController
      skip_before_action :authorize_admin, only: [:set]

      def set
        requested_locale = params[:switch_to_locale].to_s.presence

        if locale_is_available?(requested_locale)
          I18n.locale = requested_locale
          session[set_user_language_locale_key] = requested_locale
          respond_to do |format|
            format.json { render json: { locale: requested_locale, location: spree.admin_url } }
            format.html { redirect_back_or_to spree.admin_url, notice: t('spree.locale_changed') }
          end
        else
          respond_to do |format|
            format.json { render json: { locale: I18n.locale }, status: 404 }
            format.html { redirect_back_or_to spree.admin_url, error: t('spree.error') }
          end
        end
      end

      private

      def locale_is_available?(locale)
        locale && I18n.available_locales.include?(locale.to_sym)
      end
    end
  end
end
